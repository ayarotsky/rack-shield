# frozen_string_literal: true

module Rack
  class Shield
    class RedisConnection < SimpleDelegator
      def initialize(connection)
        super
        validate!
      end

      def fb_push(key, replenish_rate, tokens)
        connection.call('shield.fb_push', key, replenish_rate, tokens)
      end

      private

      def validate!
        return if valid?
        raise ArgumentError,
              'must be a connection to a redis server with ' \
              '"redis-shield" module included'
      end

      def valid?
        connection.module('list')
                  .flatten
                  .map(&:to_s)
                  .map(&:downcase)
                  .include?('shield')
      end

      def connection
        __getobj__
      end
    end
  end
end
