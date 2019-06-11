# frozen_string_literal: true

require 'rack'
require 'redis'

module Rack
  class Shield
    autoload :Bucket, 'rack/shield/bucket'
    autoload :RedisConnection, 'rack/shield/redis_connection'
    autoload :Configurable, 'rack/shield/configurable'
    autoload :Check, 'rack/shield/check'

    include Configurable

    def initialize(app)
      @app = app
    end

    def call(env)
      check = Check.new(@app, buckets, env)
      logger.info(check.explanation)
      check.response.call(env)
    end
  end
end
