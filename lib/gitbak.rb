require 'io/console'
require 'json'
require 'open-uri'

require 'gitbak/version'

# --

module GitBak

  APIS = {
    bb:   ->(user) { "api.bitbucket.org/1.0/users/#{user}"  },
    gh:   ->(user) { "api.github.com/users/#{user}/repos"   },
    gist: ->(user) { "api.github.com/users/#{user}/gists"   },
  }

  REMOTES = {                                                   # {{{1
    bb: {
      ssh:    ->(u,r) { "git@bitbucket.org:#{u}/#{r}.git" },
      https:  ->(u,r) { "https://bitbucket.org/#{u}/#{r}.git" },
    },
    gh: {
      ssh:    ->(u,r) { "git@github.com:#{u}/#{r}.git" },
      https:  ->(u,r) { "https://github.com/#{u}/#{r}.git" },
    },
    gist: {
      ssh:    ->(id)  { "git@gist.github.com:#{id}.git" },
      https:  ->(id)  { "https://gist.github.com/#{id}.git" },
    },
  }                                                             # }}}1

  REMOTE = ->(s, x) { REMOTES[s][x.fetch(:method, :ssh).to_sym] }

  class << self

    def die (msg)
      STDERR.puts msg
      exit 1
    end

    def exists? (path)
      File.exists?(path) or File.symlink?(path)
    end

    def sys (cmd, *args)
      p 'sys:', cmd, args                                       # TODO
      # system [cmd, cmd], *args or raise 'OOPS'                # TODO
    end

    def prompt (prompt, hide = false)                           # {{{1
      STDOUT.print prompt
      STDOUT.flush

      if hide
        STDIN.noecho { |i| i.readline }
      else
        STDIN.readline
      end .chomp
    end                                                         # }}}1

    # --

    def api_get (service, user, auth)
      open "https://#{APIS[service][user]}",
        http_basic_authentication: auth && [auth[:user], auth[:pass]]
    end

    def repo_name (remote)
      File.basename(remote).sub(/\.git$/, '')
    end

    def mirror (remote, dir)                                    # {{{1
      name      = repo_name remote
      name_     = name + '.git'
      repo_dir  = "#{dir}/#{name_}"

      p 'mkdir:', dir                                           # TODO
      # FileUtils::mkdir_p dir                                  # TODO

      if exists? repo_dir
        FileUtils.cd(repo_dir) do
          sys *%w{ git remote update }
        end
      else
        FileUtils.cd(dir) do
          sys *( %w{ git clone --mirror -n } + [remote, name_] )
        end
      end
    end                                                         # }}}1O

    # --

    def repos_bitbucket (x, auth)                               # {{{1
      rem = REMOTE[:bitbucket, x]

      api_get(:bitbucket, x[:user], auth)['repositories'] \
        .filter { |r| r['scm'] == 'git' } .map do |r|
          { remote: rem[x[:user], r['name']],
            description: r['description'] }
        end
    end                                                         # }}}1

    def repos_github (x, auth)                                  # {{{1
      rem = REMOTE[:github, x]

      api_get(:github, x[:user], auth).map do |r|
        { remote: rem[x[:user], r['name']],
          description: r['description'] }
      end
    end                                                         # }}}1

    def repos_gist (x, auth)                                    # {{{1
      rem = REMOTE[:gist, x]

      api_get(:gist, x[:user], auth).map do |r|
        { remote: rem[r['id']],
          description: r['description'] }
      end
    end                                                         # }}}1

    # --

    def mirror_service (service, x, auth)                       # {{{1
      auth_ = auth[x[ x[:auth] == true ? :user : :auth ]]
      repos = send "repos_#{service}", x, auth_

      repos.each do |r|
        p 'repo:', r                                            # TODO
        mirror r[:remote]                                       # TODO
      end
    end                                                         # }}}1

    # --

    def main (config)                                           # {{{1
      %w{ bitbucket github gist }.map(&:to_sym).each do |service|
        config[service].each do |x|
          mirror_service service, x, config[:auth][service]
        end
      end
    end                                                         # }}}1

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
