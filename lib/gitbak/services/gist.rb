# --                                                            ; {{{1
#
# File        : gitbak/services/gist.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-02-19
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

require 'gitbak'
require 'gitbak/services/github'

module GitBak::Services

  module Gist

    API     = 'https://api.github.com/gists'
    SSH     = -> id { "git@gist.github.com:#{id}.git"     }
    HTTPS   = -> id { "https://gist.github.com/#{id}.git" }

    HEADERS = GitHub::HEADERS

    def self.configure(cfg, dir, opts = {})                     # {{{1
      u = opts[:user] or raise 'no user'                        # TODO
      c = cfg[:gist] ||= []
      a = if opts[:auth] == false
        nil
      elsif opts[:auth] == :github
        (cfg[:github].find { |x| x[:user] == u })[:auth]
      elsif opts[:token]
        t = GitBak::Misc.prompt "token for gist/#{u}: ", true
        { user: t, pass: '' }
      else
        p = GitBak::Misc.prompt "password for gist/#{u}: ", true
        { user: u, pass: p }
      end
      c << { dir: dir, user: u, auth: a, method: opts[:method] }
    end                                                         # }}}1

    def self.fetch(cfg, verbose)                                # {{{1
      pag = GitHub.method :next_page; join = GitBak.method :cat_json
      (cfg[:gist] || []).each do |x|
        meth = x[:method] == :https ? HTTPS : SSH
        info = "gist/#{x[:user]}"
        print "fetching #{info} ..." if verbose
        repos = GitBak.paginate API, HEADERS, info, x[:auth], nil,
          pag, join
        x[:repos] = repos.map do |r|
          { name: r['id'], remote: meth[r['id']],
            description: r['description'] }
        end
        puts " #{repos.length} repositories" if verbose
      end
    end                                                         # }}}1

    def self.mirror(cfg, verbose, noact)                        # {{{1
      (cfg[:gist] || []).each do |x|
        x[:repos].each do |r|
          GitBak.show_mirror 'gist', x[:user], r[:name], r[:description]
          GitBak.mirror_repo verbose, noact, r[:remote], x[:dir]
          puts if verbose
        end
      end
    end                                                         # }}}1

    def self.summarise(cfg)
      (cfg[:gist] || []).each do |x|
        GitBak.show_summary "gist/#{x[:user]}", x[:repos].length
      end
    end

  end

  GitBak::SERVICES[:gist] = Gist

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
