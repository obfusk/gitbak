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

    # deep copy using Marshal
    def self.deepdup (obj)
      Marshal.load(Marshal.dump obj)
    end

    # print msg to stderr and exit
    def self.die! (msg)
      STDERR.puts msg
      exit 1
    end

    # does file/dir or symlink exists?
    def self.exists? (path)
      File.exists?(path) or File.symlink?(path)
    end

    # prompt for line; optionally hide input
    def self.prompt (prompt, hide = false)                      # {{{1
      STDOUT.print prompt
      STDOUT.flush

      if hide
        line = STDIN.noecho { |i| i.gets }
        STDOUT.puts
      else
        line = STDIN.gets
      end

      line and line.chomp
    end                                                         # }}}1

    # execute command; raises SysError on failure; optionally verbose
    def self.sys (verbose, cmd, *args)
      puts "$ #{ ([cmd] + args).join ' ' }" if verbose
      system [cmd, cmd], *args or raise SysError,
        "failed to run command #{ ([cmd] + args) } (#$?)"
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
