[]: {{{1

    File        : README
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-02-19

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
    Version     : v0.5.0

[]: }}}1

## Description

  gitbak - bitbucket/github/gist backup

  GitBak mirrors Bitbucket/GitHub/Gist repositories; paths, users, and
  authentication are specified in ~/.gitbak.

  When run, gitbak:

  * asks for passwords;
  * lists repositories using APIs - authenticating if necessary;
  * clones/updates repositories;
  * shows a summary (if verbose)

## Usage

```bash
$ gitbak --help                                     # show options
$ vim ~/.gitbak                                     # configure
$ gitbak --no-act                                   # dry run
$ gitbak -v                                         # mirror
$ time gitbak -v 2>&1 | tee "$(date +%Y%m%d)".log   # w/ logfile
```

## Installing

```bash
$ gem install gitbak                                # rubygems
```

  Get it at https://github.com/obfusk/gitbak.  Depends: git, ruby.

## Configuration

### Example

```ruby
# ~/.gitbak
dir = "#{ Dir.home }/__mirror__/#{ Time.new.strftime '%Y%m%d' }"
%w{ bob alice }.each do |u|
  bitbucket  "#{dir}/#{u}/bitbucket", user: u
  github     "#{dir}/#{u}/github"   , user: u, token: true
  gist       "#{dir}/#{u}/gist"     , user: u, auth: :github
end
```

### Methods

```ruby
bitbucket repo #, options...
github    repo #, options...
gist      repo #, options...
```

### Options

```ruby
user:   "username"    # mandatory
token:  true          # use token instead of user/pass (default: false)
auth:   false         # use authentication (default: true);
                        use :github w/ gist to re-use github auth
method: :https        # clone method (default: :ssh);
                        NB: https auth not implemented yet
```

## TODO

  Some things that may be useful/implemented at some point.

  * ask password again on typo (^D) or auth fail
  * tests?
  * better error handling?

#

  * custom services (should be easy to add already)
  * metadata (issues, wikis, ...)
  * teams/organisations
  * starred repos/gists
  * filtering
  * oauth?

#

  * specify ssh key(s)?
  * https clone auth?

## License

  GPLv3+ [1].

## References

  [1] GNU General Public License, version 3
  --- http://www.gnu.org/licenses/gpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
