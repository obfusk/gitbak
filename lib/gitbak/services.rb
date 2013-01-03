# --                                                            ; {{{1
#
# File        : gitbak/services.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-01-03
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'gitbak/misc'

require 'json'
require 'open-uri'

# --

# gitbak namespace
module GitBak

  # git hosting services
  module Services

    # authentication error
    class AuthError < GitBak::Error; end

    # --

    # avaliable services
    SERVICES = %w{ bitbucket github gist }.map(&:to_sym)

    # use another service's authentication
    USE_AUTH = { gist: :github }

    # API urls
    APIS = {
      bitbucket:  ->(user) { "api.bitbucket.org/1.0/users/#{user}"  },
      github:     ->(user) { "api.github.com/users/#{user}/repos"   },
      gist:       ->(user) { "api.github.com/users/#{user}/gists"   },
    }

    # remote urls
    REMOTES =                                                   # {{{1
    {
      bitbucket: {
        ssh:    ->(u, r)  { "git@bitbucket.org:#{u}/#{r}.git"     },
        https:  ->(u, r)  { "https://bitbucket.org/#{u}/#{r}.git" },
      },
      github: {
        ssh:    ->(u, r)  { "git@github.com:#{u}/#{r}.git"        },
        https:  ->(u, r)  { "https://github.com/#{u}/#{r}.git"    },
      },
      gist: {
        ssh:    ->(id)    { "git@gist.github.com:#{id}.git"       },
        https:  ->(id)    { "https://gist.github.com/#{id}.git"   },
      },
    }                                                           # }}}1

    # long keyword^wsymbol ;-)
    AUTH = :http_basic_authentication

    # --

    # get data from API
    # @raise AuthError on 401
    def self.api_get (service, user, auth)                      # {{{1
      url   = "https://#{APIS[service][user]}"
      opts  = auth ? { AUTH => [auth[:user], auth[:pass]] } : {}

      begin
        data = open url, opts
      rescue OpenURI::HTTPError => e
        if e.io.status[0] == '401'
          raise AuthError,
            "401 for #{auth[:user]} on #{service}/#{user}"
        else
          raise
        end
      end

      data
    end                                                         # }}}1

    # get repositories from service; uses api_get if service in APIS,
    # api_get_<service> otherwise
    #
    # @return [<Hash>] [!{name:, remote:, description:},...]
    def self.repositories (service, cfg, auth)
      rem   = REMOTES[service][cfg.fetch(:method, :ssh).to_sym]
      args  = [service, cfg[:user], auth]
      data  = APIS[service] ? api_get(*args) :
                send("api_get_#{service}", *args)
      send service, cfg, data, rem
    end

    # --

    # turn bitbucket API data into a list of repositories
    def self.bitbucket (cfg, data, rem)
      data_ = JSON.load data
      repos = data_['repositories'].select { |r| r['scm'] == 'git' }
      repos.map do |r|
        { name: r['name'], remote: rem[cfg[:user], r['name']],
          description: r['description'] }
      end
    end

    # turn github API data into a list of repositories
    def self.github (cfg, data, rem)
      JSON.load(data).map do |r|
        { name: r['name'], remote: rem[cfg[:user], r['name']],
          description: r['description'] }
      end
    end

    # turn gist API data into a list of repositories
    def self.gist (cfg, data, rem)
      JSON.load(data).map do |r|
        { name: r['id'], remote: rem[r['id']],
          description: r['description'] }
      end
    end

 end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
