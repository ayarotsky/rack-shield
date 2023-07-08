# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch

  add_filter %r{^/spec/}
end

require 'simplecov-cobertura'
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

require 'bundler/setup'
require 'rack/test'
require 'mock_redis'
require 'logger'

require 'rack/shield'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { require _1 }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Rack::Shield::TestHelpers

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
