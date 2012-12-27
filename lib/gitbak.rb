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

  class << self

    def die (msg)
      STDERR.puts msg
      exit 1
    end

    def sys (cmd, *args)
      p 'sys:', cmd, args
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

    def repo_name (repo)
      File.basename(repo).sub(/\.git$/, '')
    end

    def mirror (repo, dir)                                      # {{{1
      name  = repo_name repo
      r_dir = "#{dir}/#{name}.git"

      if File.exists? r_dir
        FileUtils.cd(r_dir) do
          sys *%w{ git remote update }
        end
      else
        FileUtils.cd(dir) do
          sys *( %w{ git clone --mirror -n } + [repo, name] )
        end
      end
    end                                                         # }}}1O

    # --

    def repos_bb (user, auth)                                   # {{{1
      api_get(:bitbucket)['repositories'].map do |x|
        ...
      end
    end                                                         # }}}1

    def repos_gh (user, auth)
      # ...
    end                                                         # }}}1

    def gists (user, auth)
      # ...
    end                                                         # }}}1

    # --

    def mirror_bb
      # ...
    end

    def mirror_gh
      # ...
    end

    def mirror_gist
      # ...
    end

    # --

    def main (config)                                           # {{{1
      config[:bitbucket].each do |x|
        mirror_bb x, config[:auth][:bitbucket]
      end

      config[:github].each do |x|
        mirror_gh x, config[:auth][:github]
      end

      config[:gist].each do |x|
        mirror_gist x, config[:auth][:github]
      end
    end                                                         # }}}1

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
