# --                                                            ; {{{1
#
# File        : gitbak/services/github.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-02-19
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

require 'gitbak'

module GitBak::Services

  module GitHub

    API     = 'https://api.github.com/user/repos?type=owner'
    SSH     = -> user, repo { "git@github.com:#{user}/#{repo}.git"      }
    HTTPS   = -> user, repo { "https://github.com/#{user}/#{repo}.git"  }

    HEADERS = { 'Accept' => 'application/vnd.github.v3+json' }

    def self.next_page(data)
      (l = data.meta['link']) &&
      (n = l.split(',').grep(/rel="next"/).first) &&
      (r = l.match(%r{<(https://[^>]*)>})) && r[1]
    end

    def self.configure(cfg, dir, opts = {})                     # {{{1
      u = opts[:user] or raise 'no user'                        # TODO
      c = cfg[:github] ||= []
      a = if opts[:auth] == false
        nil
      elsif opts[:token]
        t = GitBak::Misc.prompt "token for github/#{u}: ", true
        { user: t, pass: '' }
      else
        p = GitBak::Misc.prompt "password for github/#{u}: ", true
        { user: u, pass: p }
      end
      c << { dir: dir, user: u, auth: a, method: opts[:method] }
    end                                                         # }}}1

    def self.fetch(cfg, verbose)                                # {{{1
      pag = method :next_page; join = GitBak.method :cat_json
      (cfg[:github] || []).each do |x|
        meth = x[:method] == :https ? HTTPS : SSH
        info = "github/#{x[:user]}"
        print "fetching #{info} ..." if verbose
        repos = GitBak.paginate API, HEADERS, info, x[:auth], nil,
          pag, join
        x[:repos] = repos.map do |r|
          { name: r['name'], remote: meth[x[:user], r['name']],
            description: r['description'] }
        end
        puts " #{repos.length} repositories" if verbose
      end
    end                                                         # }}}1

    def self.mirror(cfg, verbose, noact)                        # {{{1
      (cfg[:github] || []).each do |x|
        x[:repos].each do |r|
          GitBak.show_mirror 'github', x[:user], r[:name], r[:description]
          GitBak.mirror_repo verbose, noact, r[:remote], x[:dir]
          puts if verbose
        end
      end
    end                                                         # }}}1

    def self.summarise(cfg)
      (cfg[:github] || []).each do |x|
        GitBak.show_summary "github/#{x[:user]}", x[:repos].length
      end
    end

  end

  GitBak::SERVICES[:github] = GitHub

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
