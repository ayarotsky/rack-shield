# frozen_string_literal: true

require 'rack'
require 'redis'

module Rack
  class Shield
    autoload :Bucket, 'rack/shield/bucket'
    autoload :Check, 'rack/shield/check'
    autoload :Configurable, 'rack/shield/configurable'
    autoload :RedisConnection, 'rack/shield/redis_connection'

    include Configurable

    def initialize(app)
      @app = app
    end

    def call(env)
      check = Check.new(buckets, env)
      logger.info(check.summary)
      response = check.pass? ? @app : check.throttled_response
      response.call(env)
    end
  end
end
