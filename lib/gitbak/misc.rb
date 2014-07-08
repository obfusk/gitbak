# --                                                            ; {{{1
#
# File        : gitbak/misc.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-07-08
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

require 'io/console'

# --

# gitbak namespace
module GitBak

  # base error class
  class Error < RuntimeError; end

  # miscellaneous
  module Misc

    # command execution failure
    class SysError < GitBak::Error; end

    # --

    # print msg to stderr and exit
    def self.die! (msg)
      STDERR.puts msg; exit 1
    end

    # does file/dir or symlink exists?
    def self.exists? (path)
      File.exist?(path) || File.symlink?(path)
    end

    # prompt for line; optionally hide input
    def self.prompt (prompt, hide = false)
      STDOUT.print prompt; STDOUT.flush
      (line = hide ? STDIN.noecho { |i| i.gets } .tap { STDOUT.puts }
                   : STDIN.gets) && line.chomp
    end

    # execute command
    # @raise SysError on failure
    def self.sys_ (cmd, *args)
      system [cmd, cmd], *args or raise SysError,
        "failed to run command #{ ([cmd] + args) } (#$?)"
    end

    # execute command (unless noact); optionally verbose
    # @see sys_
    def self.sys (cmd, *args)                                   # {{{1
      opts = Hash === args.last ? args.pop : {}
      puts "$ #{ ([cmd] + args).join ' ' }" \
        if opts[:verbose] or opts[:noact]
      if opts[:noact]
        puts '(not actually doing anything)'
      else
        sys_ cmd, *args
      end
    end                                                         # }}}1

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
