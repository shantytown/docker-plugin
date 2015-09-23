Gem::Specification.new do |gem|
  gem.name = 'shanty-docker-plugin'
  gem.version = '0.1.0'
  gem.homepage = 'https://github.com/shanty/docker-plugin'
  gem.license = 'MIT'

  gem.author = 'Chris Jansen'
  gem.email = 'chris.jansen@intenthq.comm'
  gem.summary = 'A short summary here.'
  gem.description = "See #{gem.homepage} for more information!"

  # Uncomment this if you plan on having an executable instead of a library.
  # gem.executables << 'your_wonderful_gem'
  gem.files = Dir['**/*'].select { |d| d =~ %r{^(README.md|bin/|ext/|lib/)} }

  # Add your dependencies here as follows:
  #
  #   gem.add_dependency 'some-gem', '~> 1.0'

  # Add your test dependencies here as follows:
  #
  #   gem.add_development_dependency 'whatever', '~> 1.0'
  #
  # Some sane defaults follow.
  gem.add_dependency 'erubis', '~> 2.7.0'
  gem.add_dependency 'docker-api', '~> 1.22.4'
  gem.add_dependency 'rugged', '~> 0.23.2'

  gem.add_development_dependency 'coveralls', '~> 0.8.2'
  gem.add_development_dependency 'filewatcher', '~> 0.5.2'
  gem.add_development_dependency 'pry-byebug', '~> 3.2'
  gem.add_development_dependency 'rspec', '~> 3.3'
  gem.add_development_dependency 'rubocop', '~> 0.34.1'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.3.1'
  gem.add_development_dependency 'vcr', '~> 2.9.3'
  gem.add_development_dependency 'webmock', '~> 1.21.0'
end