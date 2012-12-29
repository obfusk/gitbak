<!-- {{{1 -->

    File        : README
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2012-12-27

    Copyright   : Copyright (C) 2012  Felix C. Stegerman
    Version     : v0.2.0

<!-- }}}1 -->

### Description
<!-- {{{1 -->

  gitbak - bitbucket/github/gist backup

  GitBak allows you to mirror Bitbucket/GitHub/Gist repositories
  easily; you only need to specify paths, users, and authentication in
  ~/.gitbak and it does the rest.

<!-- }}}1 -->

### Usage
<!-- {{{1 -->

    $ gitbak --help                 # read documentation
    $ vim ~/.gitbak                 # configure
    $ gitbak -v                     # mirror

<!-- }}}1 -->

### Installing
<!-- {{{1 -->

    $ gem install gitbak            # rubygems

  Get it at https://github.com/obfusk/gitbak.  Depends: git, ruby.

<!-- }}}1 -->

### TODO
<!-- {{{1 -->

  Some things that may be useful/implemented at some point.

  * ask password again on typo (^D) or auth fail
  * tests?
  * better error handling?

  * custom services (should be easy to add already)
  * metadata (issues, wikis, ...)
  * teams/organisations
  * starred repos/gists
  * filtering
  * oauth?

  * specify ssh key(s)?
  * https clone auth?

<!-- }}}1 -->

### License
<!-- {{{1 -->

  GPLv2 [1].

<!-- }}}1 -->

### References
<!-- {{{1 -->

  [1] GNU General Public License, version 2
  --- http://www.opensource.org/licenses/GPL-2.0

<!-- }}}1 -->

<!-- vim: set tw=70 sw=2 sts=2 et fdm=marker : -->
