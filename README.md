<!-- \{{{1 -->

    File        : README
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2013-03-20

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : v0.4.2

<!-- }}}1 -->

## Description
<!-- \{{{1 -->

  gitbak - bitbucket/github/gist backup

  GitBak mirrors Bitbucket/GitHub/Gist repositories; paths, users, and
  authentication are specified in ~/.gitbak.

  When run, gitbak:

  * asks for unspecified passwords;
  * lists repositories using APIs - authenticating if necessary;
  * clones/updates repositories;
  * shows a summary (if verbose)

<!-- }}}1 -->

## Usage
<!-- \{{{1 -->

    $ gitbak --help                   # show options
    $ vim ~/.gitbak                   # configure
    $ gitbak -v                       # mirror
    $ time gitbak -v 2>&1 | tee log   # w/ logfile

  You may want to run gitbak as a cron job.                       TODO

<!-- }}}1 -->

## Installing
<!-- \{{{1 -->

    $ gem install gitbak              # rubygems

  Get it at https://github.com/obfusk/gitbak.  Depends: git, ruby.

<!-- }}}1 -->

## Configuration
<!-- \{{{1 -->

### Example

```ruby
# ~/.gitbak

dir = "#{ Dir.home }/__mirror__/#{ Time.new.strftime '%Y%m%d' }"

GitBak.configure do |auth, services|
  %w{ bob alice }.each do |u|
    services.bitbucket  "#{dir}/#{u}/bitbucket", u, auth: true
    services.github     "#{dir}/#{u}/github"   , u, auth: true
    services.gist       "#{dir}/#{u}/gist"     , u, auth: true
  end
end
```

### Methods

    auth.<service>        user[, password]
    services.<service>    dir, user[, options]

  The (default) services are: bitbucket, github, gist.  GitBak will
  prompt for unspecified passwords.

#### Repository Options

    :auth     can be true (same user) or 'username'.
    :method   defaults to :ssh.

<!-- }}}1 -->

## TODO
<!-- \{{{1 -->

  Some things that may be useful/implemented at some point.

  * ask password again on typo (^D) or auth fail
  * tests?
  * better error handling?

<!-- -->

  * custom services (should be easy to add already)
  * metadata (issues, wikis, ...)
  * teams/organisations
  * starred repos/gists
  * filtering
  * oauth?

<!-- -->

  * specify ssh key(s)?
  * https clone auth?

<!-- }}}1 -->

## License
<!-- \{{{1 -->

  GPLv2 [1].

<!-- }}}1 -->

## References
<!-- \{{{1 -->

  [1] GNU General Public License, version 2
  --- http://www.opensource.org/licenses/GPL-2.0

<!-- }}}1 -->

<!-- vim: set tw=70 sw=2 sts=2 et fdm=marker : -->
