# frozen_string_literal: true

require 'rack'
require 'redis'

require 'rack/shield/bucket'
require 'rack/shield/check'
require 'rack/shield/configurable'
require 'rack/shield/redis_connection'

module Rack
  # Middleware that uses Redis Shield for blocking abusive requests.
  class Shield
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
