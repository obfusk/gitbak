# --                                                            ; {{{1
#
# File        : gitbak/exec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-01-03
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'gitbak'
require 'gitbak/config'

require 'optparse'

# --

# gitbak namespace
module GitBak
  # command-line executable
  module Executable

    # command-line usage
    USAGE = 'gitbak [<option(s)>]'

    # parse command line options; die on failure
    def self.parse_options (args)                               # {{{1
      args_   = args.dup
      options = { cfgfile: "#{Dir.home}/.gitbak", verbose: false,
                  noact: false }

      op = OptionParser.new do |opts|                           # {{{2
        opts.banner = USAGE

        opts.on('-c', '--config-file FILE',
                'Configuration file') do |x|
          options[:cfgfile] = x
        end

        opts.on('-v', '--[no-]verbose', 'Run verbosely') do |x|
          options[:verbose] = x
        end

        opts.on('-n', '--no-act', 'List w/o mirroring') do |x|
          options[:noact] = !x
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts GitBak::Config::INFO, '', opts
          exit
        end

        opts.on_tail('-e', '--example',
                     'Show example configuration') do
          puts GitBak::Config::CONFIG_EX
          exit
        end

        opts.on_tail('--version', 'Show version') do
          puts "gitbak v#{GitBak::VERSION}"
          exit
        end
      end                                                       # }}}2

      begin
        op.parse! args_
      rescue OptionParser::ParseError => e
        GitBak::Misc.die! "#{e}\n\n#{op}"
      end

      GitBak::Misc.die! "usage: #{USAGE}" unless args_.length == 0

      options
    end                                                         # }}}1

    # parse configuration file; die on failure
    def self.parse_cfgfile (file)
      GitBak::Misc.die! "configuration file (#{file}) not found" \
        unless GitBak::Misc.exists? file

      GitBak::Config.load file
    end

    # run!
    def self.main (args = nil)
      options = parse_options (args or ARGV)
      cfg     = parse_cfgfile options[:cfgfile]

      GitBak.main options[:verbose], options[:noact], cfg.data
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
