# --                                                            ; {{{1
#
# File        : gitbak/services/bitbucket.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-07-08
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

require 'gitbak'

module GitBak::Services

  module Bitbucket

    API     = -> user { "https://bitbucket.org/api/2.0/repositories/#{user}" }
    SSH     = -> user, repo { "git@bitbucket.org:#{user}/#{repo}.git"      }
    HTTPS   = -> user, repo { "https://bitbucket.org/#{user}/#{repo}.git"  }

    def self.to_json(data)
      JSON.parse data
    end

    def self.next_page(data)
      data['next']
    end

    def self.cat_json_values(pages)
      pages.map { |x| x['values'] } .flatten(1) .sort_by { |x| x['name'] }
    end

    def self.configure(cfg, dir, opts = {})                     # {{{1
      u = opts[:user] or raise 'no user'                        # TODO
      c = cfg[:bitbucket] ||= []
      a = if opts[:auth] == false
        nil
      else
        p = GitBak::Misc.prompt "password for bitbucket/#{u}: ", true
        { user: u, pass: p }
      end
      c << { dir: dir, user: u, auth: a, method: opts[:method] }
    end                                                         # }}}1

    def self.fetch(cfg, verbose)                                # {{{1
      f     = method :to_json; pag = method :next_page
      join  = method :cat_json_values
      (cfg[:bitbucket] || []).each do |x|
        meth = x[:method] == :https ? HTTPS : SSH
        info = "bitbucket/#{x[:user]}"
        print "fetching #{info} ..." if verbose
        repos = GitBak.paginate API[x[:user]], nil, info, x[:auth], f,
          pag, join
        x[:repos] = repos.select { |r| r['scm'] == 'git' } .map do |r|
          { name: r['name'], remote: meth[x[:user], r['name']],
            description: r['description'] }
        end
        puts " #{repos.length} repositories" if verbose
      end
    end                                                         # }}}1

    def self.mirror(cfg, verbose, noact)                        # {{{1
      (cfg[:bitbucket] || []).each do |x|
        x[:repos].each do |r|
          GitBak.show_mirror 'bitbucket', x[:user], r[:name], r[:description]
          GitBak.mirror_repo verbose, noact, r[:remote], x[:dir]
          puts if verbose
        end
      end
    end                                                         # }}}1

    def self.summarise(cfg)
      (cfg[:bitbucket] || []).each do |x|
        GitBak.show_summary "bitbucket/#{x[:user]}", x[:repos].length
      end
    end

  end

  GitBak::SERVICES[:bitbucket] = Bitbucket

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
