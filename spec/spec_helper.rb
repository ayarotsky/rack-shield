require "bundler/setup"
require 'rspec/its'
require "rack/test"
require 'pry'

require "rack/shield"

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  include Rack::Test::Methods
  include Rack::Shield::TestHelpers

  config.before do
    Rack::Shield::Request.configure do |request_config|
      request_config.count = nil
      request_config.user_id = nil
    end
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
