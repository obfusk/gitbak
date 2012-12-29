require 'gitbak/eval'
require 'gitbak/misc'
require 'gitbak/services'

# --

# gitbak namespace
module GitBak

  # configuration
  module Config                                                 # {{{1

    # configuration error
    class ConfigError < GitBak::Error; end

    # --

    # description
    INFO = 'gitbak - bitbucket/github/gist backup'

    # configuration example
    CONFIG_EX = <<-END.gsub(/^ {6}/, '')                        # {{{2
      === Example Configuration ===

        $ cat >> ~/.gitbak
        dir = '/path/to/mirrors/dir'

        GitBak.configure do |auth, repos|
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
                                                                # }}}2

    # --

    # configuration base class
    class ServiceCfg                                            # {{{2
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
    end                                                         # }}}2

    # authentication configuration
    class AuthCfg < ServiceCfg                                  # {{{2
      # set service auth
      def _service (name, user, pass = nil)
        (@_data[name] ||= {})[user] = { user: user, pass: pass }
      end
    end                                                         # }}}2

    # repository configuration
    class ReposCfg < ServiceCfg                                 # {{{2
      # set service repo
      def _service (name, dir, user, opts = {})
        c = opts.merge dir: dir, user: user
        c[:auth] = c[:user] if c[:auth] == true
        (@_data[name] ||= []) << c
      end
    end                                                         # }}}2

    # authentication and repository configuration
    class Cfg                                                   # {{{2
      # data
      attr_reader :auth, :repos

      # init
      def initialize
        @auth   = AuthCfg.new
        @repos  = ReposCfg.new
      end

      # get data
      def data                                                  # {{{3
        auth  = @auth._data
        repos = @repos._data

        { auth: auth, repos: repos }
      end                                                       # }}}3
    end                                                         # }}}2

    # --

    # load configuration file
    def self.load (file)                                        # {{{2
      cfg = eval File.read(file), GitBak::Eval.new.binding, file # ???

      raise ConfigError,  "[#{file}] isn't a GitBak::Config::Cfg " \
                          "(#{cfg.class} instead)." \
        unless Cfg === cfg

      cfg
    end                                                         # }}}2

  end                                                           # }}}1

  # configure
  def self.configure (&block)
    cfg = Config::Cfg.new
    block[cfg.auth, cfg.repos]
    cfg
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
