# frozen_string_literal: true

module Rack
  class Shield
    module Configurable
      def self.included(base)
        base.extend ClassMethods
      end

      def buckets
        self.class.buckets
      end

      def logger
        self.class.logger
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
          @logger ||= NullLogger.new
        end

        def buckets
          @buckets ||= []
        end
      end
    end
  end
end
