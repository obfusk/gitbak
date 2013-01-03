# --                                                            ; {{{1
#
# File        : gitbak.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-01-03
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'gitbak/misc'
require 'gitbak/services'
require 'gitbak/version'

require 'fileutils'

# --

# gitbak namespace
module GitBak

  # extract name from remote; e.g. "git@server:foo/bar.git" and
  # "https://server/foo/bar.git" become "bar"
  def self.repo_name (remote)
    remote.sub(%r!^.*[/:]!, '').sub(/\.git$/, '')
  end

  # clone (from remote) or update repository (in dir); optionally
  # verbose
  def self.mirror_repo (verbose, noact, remote, dir)            # {{{1
    name      = repo_name remote
    name_     = name + '.git'
    repo_dir  = "#{dir}/#{name_}"

    sys = ->(args) { Misc.sys *args, verbose: verbose, noact: noact }

    FileUtils.mkdir_p dir

    if Misc.exists? repo_dir
      puts "$ cd #{repo_dir}" if verbose
      FileUtils.cd(repo_dir) do
        sys[ %w{ git remote update } ]
      end
    else
      puts "$ cd #{dir}" if verbose
      FileUtils.cd(dir) do
        sys[ %w{ git clone --mirror -n } + [remote, name_] ]
      end
    end
  end                                                           # }}}1

  # --

  # check auth; ask passwords
  def self.process_config (config)                              # {{{1
    config_ = Misc.deepdup config

    config_[:repos].each do |service, cfgs|
      auth = config_[:auth][service] ||= {}
      cfgs.each do |cfg|
        user = cfg[:auth]
        auth[user] = { user: user, pass: nil } if user && !auth[user]
      end
    end

    config_[:auth].each do |service, auth|
      next if GitBak::Services::USE_AUTH[service]
      auth.each_value do |x|
        p = "#{service} password for #{x[:user]}: "
        x[:pass] ||= Misc.prompt p, true                        # TODO
      end
    end

    [config_[:auth], config_[:repos]]
  end                                                           # }}}1

  # fetch repository lists; optionally verbose
  def self.fetch (verbose, auth, repos)                         # {{{1
    repos.map do |service, cfgs|
      au = auth[Services::USE_AUTH.fetch service, service]
      cfgs.map do |cfg|
        puts "listing #{service}/#{cfg[:user]} ..." if verbose

        begin
          rs = Services.repositories service, cfg, au[cfg[:auth]]
        rescue Services::AuthError => e
          Misc.die! "authentication failure: #{e}"
        end

        [service, cfg[:user], cfg[:dir], rs]
      end
    end .flatten 1
  end                                                           # }}}1

  # mirror repositories; optionally verbose
  def self.mirror (verbose, noact, repos)                       # {{{1
    repos.each do |s, usr, dir, rs|
      rs.each do |r|
        name, desc = r[:name], r[:description]
        puts "==> #{s} | #{usr} | #{name} | #{desc} <==" if verbose
        mirror_repo verbose, noact, r[:remote], dir
        puts if verbose
      end
    end
  end                                                           # }}}1

  # print summary
  def self.summary (repos)                                      # {{{1
    puts '', '=== Summary ===', ''
    repos.each do |service, usr, dir, rs|
      printf "  %-15s for %-20s: %10s repositories\n",
        service, usr, rs.length
    end
    puts
  end                                                           # }}}1

  # --

  # run!
  def self.main (verbose, noact, config)
    auth, repos   = process_config config
    repositories  = fetch verbose, auth, repos
    mirror verbose, noact, repositories
    summary repositories if verbose
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
