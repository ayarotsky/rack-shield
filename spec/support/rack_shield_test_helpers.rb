# frozen_string_literal: true

require 'yaml'

module Rack::Shield::TestHelpers
  def app
    Rack::Builder.new do
      use Rack::Lint
      use Rack::Shield
      use Rack::Lint

      run ->(_env) { [200, {}, ['Hello World']] }
    end
  end

  def build_rack_env(attributes = {})
    env_config = File.join(File.dirname(__FILE__), 'rack_env.yml')
    YAML.safe_load(File.read(env_config)).merge(attributes)
  end
end
