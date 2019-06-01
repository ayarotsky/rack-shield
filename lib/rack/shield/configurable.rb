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
          bucket = Bucket.new(self)
          yield bucket
          buckets << bucket
        end

        def redis=(connection)
          unless valid_redis_connection?(connection)
            raise ArgumentError,
                  'must be a connection to a redis server with ' \
                  'redis-shield module included'
          end

          @redis = connection
        end

        def buckets
          @buckets ||= []
        end

        private

        def valid_redis_connection?(connection)
          connection.present? &&
            connection.call('module', 'list')
                      .flatten
                      .map(&:to_s)
                      .map(&:downcase)
                      .include?('shield')
        end
      end
    end
  end
end
