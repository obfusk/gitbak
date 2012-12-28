require File.expand_path('../lib/gitbak/version', __FILE__)

Gem::Specification.new do |s|
  s.name                  = 'gitbak'
  s.homepage              = 'https://github.com/obfusk/gitbak'
  s.summary               = 'bitbucket/github/gist backup'

  s.description = <<-END.gsub(/^ {4}/, '')
    GitBak allows you to mirror Bitbucket/GitHub/Gist repositories
    easily; you only need to specify paths, users, and authentication
    in ~/.gitbak and it does the rest.
  END

  s.version               = GitBak::VERSION
  s.date                  = GitBak::DATE

  s.authors               = [ 'Felix C. Stegerman' ]
  s.email                 = %w{ flx@obfusk.net }

  s.license               = 'GPLv2'

  s.files                 = Dir[*%w{ README bin/gitbak lib/**/*.rb }]
  s.executables           = %w{ gitbak }

  s.add_runtime_dependency  'json'

  s.required_ruby_version = '>= 1.9.1'
end
