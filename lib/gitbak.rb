require 'fileutils'
require 'io/console'
require 'json'
require 'open-uri'

require 'gitbak/version'

# --

module GitBak

  APIS = {
    bitbucket:  ->(user) { "api.bitbucket.org/1.0/users/#{user}"  },
    github:     ->(user) { "api.github.com/users/#{user}/repos"   },
    gist:       ->(user) { "api.github.com/users/#{user}/gists"   },
  }

  REMOTES = {                                                   # {{{1
    bitbucket: {
      ssh:    ->(u,r) { "git@bitbucket.org:#{u}/#{r}.git" },
      https:  ->(u,r) { "https://bitbucket.org/#{u}/#{r}.git" },
    },
    github: {
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

    def sys (verbose, cmd, *args)
      puts "  $ #{([cmd] + args).join ' '}" \
        if verbose
      system [cmd, cmd], *args \
        or raise 'OOPS'                                         # TODO
    end

    def prompt (prompt, hide = false)                           # {{{1
      STDOUT.print prompt
      STDOUT.flush

      if hide
        line = STDIN.noecho { |i| i.readline }
        STDOUT.puts
        line
      else
        STDIN.readline
      end .chomp
    end                                                         # }}}1

    # --

    def api_get (service, user, auth)
      opts = auth ? { http_basic_authentication:
                      [auth[:user], auth[:pass]] } : {}

      JSON.load open("https://#{APIS[service][user]}", opts)
    end

    def repo_name (remote)
      remote.sub(%r!^.*[/:]!, '').sub(/\.git$/, '')
    end

    def mirror (remote, dir, verbose)                           # {{{1
      name      = repo_name remote
      name_     = name + '.git'
      repo_dir  = "#{dir}/#{name_}"

      FileUtils.mkdir_p dir

      if exists? repo_dir
        FileUtils.cd(repo_dir) do
          sys verbose, *%w{ git remote update }
        end
      else
        FileUtils.cd(dir) do
          sys verbose,
            *( %w{ git clone --mirror -n } + [remote, name_] )
        end
      end
    end                                                         # }}}1O

    # --

    def repos_bitbucket (x, auth)                               # {{{1
      rem = REMOTE[:bitbucket, x]

      api_get(:bitbucket, x[:user], auth)['repositories'] \
        .select { |r| r['scm'] == 'git' } .map do |r|
          { remote: rem[x[:user], r['name']],
            description: r['description'], name: r['name'] }
        end
    end                                                         # }}}1

    def repos_github (x, auth)                                  # {{{1
      rem = REMOTE[:github, x]

      api_get(:github, x[:user], auth).map do |r|
        { remote: rem[x[:user], r['name']],
          description: r['description'], name: r['name'] }
      end
    end                                                         # }}}1

    def repos_gist (x, auth)                                    # {{{1
      rem = REMOTE[:gist, x]

      api_get(:gist, x[:user], auth).map do |r|
        { remote: rem[r['id']],
          description: r['description'], name: r['id'] }
      end
    end                                                         # }}}1

    # --

    def mirror_service (service, x, auth, verbose)              # {{{1
      puts "#{service} for #{x[:user]} ..."

      auth_ = auth && auth[x[ x[:auth] == true ? :user : :auth ]]
      repos = send "repos_#{service}", x, auth_

      repos.each do |r|
        d = r[:description]
        puts "==> #{service} | #{x[:user]} | #{r[:name]} | #{d} <==" \
          if verbose                                            # TODO
        mirror r[:remote], x[:dir], verbose
        puts if verbose
      end

      repos.length
    end                                                         # }}}1

    # --

    def main (config)                                           # {{{1
      s = {}

      %w{ bitbucket github gist }.map(&:to_sym).each do |service|
        s[service] = {}
        config[service].each do |x|
          s[service][x[:user]] = mirror_service service, x,
            config[:auth][service], config[:verbose]
        end
      end

      if config[:verbose]
        puts '', "=== Summary ===", ''
        s.each_pair do |service, info|
          info.each_pair do |user, len|
            printf "  %-15s for %-20s: %10s repositories\n",
              service, user, len
          end
        end
        puts
      end
    end                                                         # }}}1

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
