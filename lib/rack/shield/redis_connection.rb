# frozen_string_literal: true

module Rack
  class Shield
    class RedisConnection < SimpleDelegator
      def initialize(connection)
        super
        validate!
      end

      def shield_absorb(key, replenish_rate, period, tokens = nil)
        args = [key, replenish_rate, period]
        args << tokens if tokens
        connection.call('SHIELD.absorb', *args)
      end

      private

      def validate!
        return if valid?

        raise ArgumentError,
              'must be a connection to redis with "redis-shield" module'
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
