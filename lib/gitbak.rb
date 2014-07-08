# --                                                            ; {{{1
#
# File        : gitbak.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-07-08
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : GPLv3+
#
# --                                                            ; }}}1

require 'gitbak/misc'

require 'fileutils'
require 'json'
require 'open-uri'

# --

# gitbak namespace
module GitBak

  module Services; end

  # authentication error
  class AuthError < Error; end

  SERVICES = {}

  # --

  # extract name from remote; e.g. "git@server:foo/bar.git" and
  # "https://server/foo/bar.git" become "bar"
  def self.repo_name(remote)
    remote.sub(%r!^.*[/:]!, '').sub(/\.git$/, '')
  end

  # clone (from remote) or update repository (in dir), optionally
  # verbose
  def self.mirror_repo(verbose, noact, remote, dir)             # {{{1
    name      = repo_name remote
    name_     = name + '.git'
    repo_dir  = "#{dir}/#{name_}"
    sys       = -> args { Misc.sys *args, verbose: verbose, noact: noact }
    FileUtils.mkdir_p dir
    if Misc.exists? repo_dir
      puts "$ cd #{repo_dir}" if verbose or noact
      FileUtils.cd(repo_dir) do
        sys[ %w{ git remote update } ]
      end
    else
      puts "$ cd #{dir}" if verbose or noact
      FileUtils.cd(dir) do
        sys[ %w{ git clone --mirror -n } + [remote, name_] ]
      end
    end
  end                                                           # }}}1

  # --

  # get data from API, optionally w/ auth
  # @raise AuthError on 401
  def self.api_get(url, opts, info, auth, f)                    # {{{1
    g = f || -> x { x }
    o = auth ? { http_basic_authentication:
                   [auth[:user],auth[:pass]] } : {}
    begin
      g[open url, o.merge(opts || {})]
    rescue OpenURI::HTTPError => e
      if e.io.status[0] == '401'
        raise AuthError, "401 for #{auth[:user]} #{info}"
      else
        raise
      end
    end
  end                                                           # }}}1

  # get paginated data from API
  def self.paginate(url, opts, info, auth, f, pag, join)
    pages = []; g = -> { api_get url, opts, info, auth, f }
    while url; pages << data = g[]; url = pag[data]; end
    join[pages]
  end

  # concatenate json
  def self.cat_json(pages)
    pages.map { |x| JSON.parse x } .flatten 1
  end

  # --

  # show info about mirroring
  def self.show_mirror(*args)
    puts "==> #{args*' | '} <=="
  end

  # show info about number of repos
  def self.show_summary(info, n)
    printf "  %3d | %s\n", n, info
  end

  # --

  # configure
  def self.configure(file)                                      # {{{1
    c = {}; x = Object.new
    x.instance_eval { def self._binding; binding; end }
    SERVICES.each_pair do |k,v|
      x.define_singleton_method(k) { |*a| v.configure c, *a }
    end
    x._binding.eval File.read(file), file; c
  end                                                           # }}}1

  # run!
  def self.main(verbose, noact, config)                         # {{{1
    SERVICES.each_pair do |k,v|
      begin
        v.fetch config, verbose
      rescue AuthError => e
        Misc.die! "authentication failure: #{e}"
      end
    end
    puts
    SERVICES.each_pair do |k,v|
      v.mirror config, verbose, noact
    end
    puts
    if verbose
      puts '=== Summary ==='; puts
      SERVICES.each_pair do |k,v|
        v.summarise config
      end
      puts
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
