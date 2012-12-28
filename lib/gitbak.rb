require 'gitbak/misc'
require 'gitbak/services'
require 'gitbak/version'

require 'fileutils'

# --

# gitbak namespace
module GitBak

  # configuration error
  class ConfigError < RuntimeError; end

  # --

  # extract name from remote; e.g. "git@server:foo/bar.git" and
  # "https://server/foo/bar.git" become "bar"
  def self.repo_name (remote)
    remote.sub(%r!^.*[/:]!, '').sub(/\.git$/, '')
  end

  # clone (from remote) or update repository (in dir); optionally
  # verbose
  def self.mirror_repo (verbose, remote, dir)                   # {{{1
    name      = repo_name remote
    name_     = name + '.git'
    repo_dir  = "#{dir}/#{name_}"

    FileUtils.mkdir_p dir

    if Misc.exists? repo_dir
      FileUtils.cd(repo_dir) do
        Misc.sys verbose, *%w{ git remote update }
      end
    else
      FileUtils.cd(dir) do
        Misc.sys verbose,
          *( %w{ git clone --mirror -n } + [remote, name_] )
      end
    end
  end                                                           # }}}1

  # --

  # check auth; ask passwords
  def self.configure! (config)                                  # {{{1
    config[:repos].each do |service, cfgs|
      auth = config[:auth][service]
      cfgs.each do |cfg|
        user = cfg[:auth]
        auth[user] = { user: user, pass: nil } if user && !auth[user]
      end
    end

    config[:auth].each do |service, auth|
      auth.each_value do |x|
        p = "#{service} password for #{x[:user]}: "
        x[:pass] ||= Misc.prompt p, true                        # TODO
      end
    end

    [config[:auth], config[:repos]]
  end                                                           # }}}1

  # fetch repository lists; optionally verbose
  def self.fetch (verbose, auth, repos)                         # {{{1
    repos.map do |service, cfgs|
      cfgs.map do |cfg|
        puts "listing #{service} for #{cfg[:user]} ..." if verbose
        rs = Services.repositories service, cfg, auth[cfg[:user]]
        [service, cfg[:user], cfg[:dir], rs]
      end
    end .flatten 1
  end                                                           # }}}1

  # mirror repositories; optionally verbose
  def self.mirror verbose, repos                                # {{{1
    repos.each do |s, usr, dir, rs|
      rs.each do |r|
        name, desc = r[:name], r[:description]
        puts "==> #{s} | #{usr} | #{name} | #{desc} <==" if verbose
        mirror_repo verbose, r[:remote], dir
        puts if verbose
      end
    end
  end                                                           # }}}1

  # print summary
  def self.summary repos                                        # {{{1
    puts '', '=== Summary ===', ''
    repos.each do |service, usr, dir, rs|
      printf "  %-15s for %-20s: %10s repositories\n",
        service, usr, rs.length
    end
    puts
  end                                                           # }}}1

  # --

  # run!
  def self.main (verbose, config)
    auth, repos   = configure! config
    repositories  = fetch verbose, auth, repos
    mirror verbose, repositories
    summary repositories if verbose
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
