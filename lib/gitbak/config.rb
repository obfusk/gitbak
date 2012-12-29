require 'gitbak/eval'

# --

# gitbak namespace
module GitBak
  # configuration
  module Config

    # configuration example, description
    INFO = <<-END.gsub(/^ {6}/, '')                             # {{{1
      gitbak - bitbucket/github/gist backup

      === Example Configuration ===

        $ cat >> ~/.gitbak
        dir = '/path/to/mirrors/dir'

        GitBak::Config do |auth, repos|
          %w{ user1 user2 }.each do |u|
            repos.bitbucket "\#{dir}/\#{u}/bitbucket", u, auth: true
            repos.github    "\#{dir}/\#{u}/github"   , u, auth: true
            repos.gist      "\#{dir}/\#{u}/gist"     , u, auth: true
          end
        end
        ^D


      === Configuration Methods ===

        auth.<service>    user[, password]
        repos.<service>   dir, user[, options]


      The (default) services are: bitbucket, github, gist.
      If a password is not specified, gitbak will prompt for it.


      === Optional Repository Options ===

        :auth     can be true (same user) or 'username'.
        :method   defaults to :ssh.
    END
                                                                # }}}1

    # --

    # configuration base class
    class ServiceCfg                                            # {{{1
      # data
      attr_reader :_data

      # init
      def initialize
        @_data = {}
      end

      # pass on to _service or super
      def method_missing (meth, *args, &block)
        if GitBak::Services::SERVICES.include? meth
          _service meth, *args
        else
          super
        end
      end
    end                                                         # }}}1

    # authentication configuration
    class AuthCfg < ServiceCfg                                  # {{{1
      # set service auth
      def _service (name, user, pass = nil)
        (@_data[name] ||= {})[user] = { user: user, pass: pass }
      end
    end                                                         # }}}1

    # repository configuration
    class ReposCfg < ServiceCfg                                 # {{{1
      # set service repo
      def _service (name, dir, user, opts = {})
        c = opts.merge dir: dir, user: user
        c[:auth] = c[:user] if c[:auth] == true
        (@_data[name] ||= []) << c
      end
    end                                                         # }}}1

    # authentication and repository configuration
    class Cfg                                                   # {{{1
      # data
      attr_reader :auth, :repos

      # init
      def initialize
        @auth   = AuthCfg.new
        @repos  = ReposCfg.new
      end

      # get data
      def data                                                  # {{{2
        auth  = @auth._data
        repos = @repos._data

        GitBak::Services::USE_AUTH.each do |to, from|
          (auth[to] ||= {}).merge auth[from] if auth[from]
        end

        { auth: auth, repos: repos }
      end                                                       # }}}2
    end                                                         # }}}1

    # --

    # load configuration file
    def self.load (file)                                        # {{{1
      cfg = eval File.read(file), GitBak::Eval.new.binding, file # ???

      warn  "[#{file}] isn't a GitBak::Config::Cfg " \
            "(#{cfg.class} instead)." \
        unless Cfg === cfg

      cfg
    end                                                         # }}}1

    # configure!
    def self.call (&block)
      cfg = Cfg.new
      block[cfg.auth, cfg.repos]
      cfg.data
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
