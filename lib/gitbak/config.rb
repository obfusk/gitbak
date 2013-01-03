# --                                                            ; {{{1
#
# File        : gitbak/config.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-01-03
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

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
