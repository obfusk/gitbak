require File.expand_path('../lib/gitbak/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'gitbak'
  s.homepage    = 'https://github.com/obfusk/gitbak'
  s.summary     = 'bitbucket/github/gist backup'

  s.description = <<-END.gsub(/^ {4}/, '')
    GitBak mirrors Bitbucket/GitHub/Gist repositories; paths, users,
    and authentication are specified in ~/.gitbak.

    When run, gitbak:

    * asks for passwords;
    * lists repositories using APIs - authenticating if necessary;
    * clones/updates repositories;
    * shows a summary (if verbose)
  END

  s.version     = GitBak::VERSION
  s.date        = GitBak::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.license     = 'GPLv3+'

  s.executables = %w{ gitbak }
  s.files       = %w{ .yardopts README.md gitbak.gemspec } \
                + Dir['lib/**/*.rb']

  s.required_ruby_version = '>= 1.9.1'
end
