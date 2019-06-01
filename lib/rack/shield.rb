# frozen_string_literal: true

require 'rack'
require 'redis'

module Rack
  class Shield
    autoload :Bucket, 'rack/shield/bucket'
    autoload :RedisConnection, 'rack/shield/redis_connection'
    autoload :Configurable, 'rack/shield/configurable'

    include Configurable

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      bucket = buckets.find { |b| b.matches?(request) }

      if bucket&.rejects?(request)
        bucket.throttled_response.call(env)
      else
        @app.call(env)
      end
    end
  end
end
