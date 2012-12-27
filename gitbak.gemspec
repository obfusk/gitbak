require File.expand_path('../lib/gitbak/version', __FILE__)

Gem::Specification.new do |s|
  s.name                  = 'gitbak'
  s.homepage              = 'https://github.com/obfusk/gitbak'

  s.summary               = 'Github/Bitbucket backup'
  s.description           = 'Github/Bitbucket backup'

  s.version               = GitBak::VERSION
  s.date                  = GitBak::DATE

  s.authors               = [ 'Felix C. Stegerman' ]
  s.email                 = [ 'flx@obfusk.net' ]

  s.license               = 'GPLv2'

  s.files                 = Dir[ 'bin/gitbak', 'lib/**.rb' ]

  s.bindir                = 'bin'
  s.require_path          = 'lib'

  s.add_runtime_dependency  'json'

  s.required_ruby_version = '>= 1.9.1'
end
