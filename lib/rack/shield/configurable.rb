# frozen_string_literal: true

require 'forwardable'

module Rack
  class Shield
    module Configurable
      extend Forwardable

      def_delegators :'self.class', :buckets, :logger

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        attr_reader :redis
        attr_writer :logger

        def configure_bucket(id)
          raise ArgumentError, 'redis connection is not configured' unless redis

          bucket = Bucket.new(id, redis)
          yield bucket
          bucket.validate!
          buckets << bucket
        end

        def redis=(connection)
          @redis = RedisConnection.new(connection)
        end

        def logger
          @logger ||= Rack::NullLogger.new(self)
        end

        def buckets
          @buckets ||= []
        end
      end
    end
  end
end
