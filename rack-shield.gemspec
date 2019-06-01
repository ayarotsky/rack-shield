# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/shield/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-shield'
  spec.version       = Rack::Shield::VERSION
  spec.authors       = ['Alex Yarotsky']
  spec.email         = ['yarotsky.alex@gmail.com']

  spec.summary       = 'Request rate limiter for rack apps'
  spec.description   = 'Rack middleware for blocking abusive requests'
  spec.homepage      = 'https://github.com/ayarotsky/rack-shield'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set
  # the 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] =
      'https://github.com/ayarotsky/rack-shield'
    spec.metadata['changelog_uri'] =
      'https://github.com/ayarotsky/rack-shield/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem
  # that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.required_ruby_version = '>= 2.4'

  spec.add_dependency 'rack', '~> 2.0'
  spec.add_dependency 'redis', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.3'
  spec.add_development_dependency 'rack-test', '~> 1.1'
  spec.add_development_dependency 'rubocop', '~> 0.49.0'
  spec.add_development_dependency 'mock_redis', '~> 0.20.0'
end
