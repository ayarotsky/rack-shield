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

      module ClassMethods
        attr_reader :redis

        def configure_bucket
          raise ArgumentError, 'redis connection is not configured' unless redis
          bucket = Bucket.new(redis)
          yield bucket
          buckets << bucket
        end

        def redis=(connection)
          @redis = RedisConnection.new(connection)
        end

        def buckets
          @buckets ||= []
        end
      end
    end
  end
end
