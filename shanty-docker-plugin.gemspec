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
  gem.add_dependency 'docker-api', '~> 1.34.2'
  gem.add_dependency 'erubis', '~> 2.7.0'
  gem.add_dependency 'rugged', '~> 0.27.4'

  gem.add_development_dependency 'coveralls', '~>0.8'
  gem.add_development_dependency 'filewatcher', '~>1.0'
  gem.add_development_dependency 'pry-byebug', '~>3.6'
  gem.add_development_dependency 'rspec', '~>3.8'
  gem.add_development_dependency 'rubocop', '~>0.58'
  gem.add_development_dependency 'rubocop-rspec', '~>1.27'
  gem.add_development_dependency 'vcr', '~> 4.0.0'
  gem.add_development_dependency 'webmock', '~> 3.4.2'
end
