require 'json'
require 'open-uri'

# --

# gitbak namespace
module GitBak
  # git services
  module Services

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
    def self.api_get (service, user, auth)
      JSON.load open("https://#{APIS[service][user]}",
        (auth ? { AUTH => [auth[:user], auth[:pass]] } : {}))
    end

    # get repositories from service; uses api_get if APIS[service],
    # api_get_<service> otherwise
    #   -> [{name:,remote:,description:},...]
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
      repos = data['repositories'].select { |r| r['scm'] == 'git' }
      repos.map do |r|
        { name: r['name'], remote: rem[cfg[:user], r['name']],
          description: r['description'] }
      end
    end

    # turn github API data into a list of repositories
    def self.github (cfg, data, rem)
      data.map do |r|
        { name: r['name'], remote: rem[cfg[:user], r['name']],
          description: r['description'] }
      end
    end

    # turn gist API data into a list of repositories
    def self.gist (cfg, data, rem)
      data.map do |r|
        { name: r['id'], remote: rem[r['id']],
          description: r['description'] }
      end
    end

 end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
