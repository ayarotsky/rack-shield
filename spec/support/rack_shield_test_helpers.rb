# frozen_string_literal: true

require 'yaml'

module Rack
  class Shield
    def self.clear_configuration
      @redis = nil
      @logger = nil
      @buckets = []
    end

    module TestHelpers
      def app
        Rack::Builder.new do
          use Rack::Lint
          use Rack::Shield
          use Rack::Lint

          run ->(_env) { [200, {}, ['Hello World']] }
        end
      end

      def build_rack_env(attributes = {})
        env_config = ::File.join(::File.dirname(__FILE__), 'rack_env.yml')
        YAML.safe_load(::File.read(env_config)).merge(attributes)
      end

      def create_bucket(**attrs)
        Rack::Shield::Bucket.new(attrs[:id], attrs[:redis_connection]).tap do |bucket|
          valid_attrs = attrs.slice(:key, :tokens, :replenish_rate, :throttled_response, :filter)
          valid_attrs.each do |attr, value|
            bucket.public_send("#{attr}=", value)
          end
        end
      end
    end
  end
end
