# frozen_string_literal: true

module Rack
  class Shield
    class Bucket
      DEFAULT_TOKENS_COUNT = 1

      attr_accessor :replenish_rate, :throttled_response, :filter, :key, :tokens

      def initialize(redis)
        @redis = redis
      end

      def tokens
        @tokens || DEFAULT_TOKENS_COUNT
      end

      def matches?(request)
        filter.nil? || filter.call(request)
      end

      def rejects?(request)
        tokens_remaining_after(request).negative?
      end

      private

      def tokens_remaining_after(request)
        @redis.fb_push(key_from(request), replenish_rate, tokens_from(request))
      end

      def key_from(request)
        key.respond_to?(:call) ? key.call(request) : key
      end

      def tokens_from(request)
        tokens.respond_to?(:call) ? tokens.call(request) : tokens
      end
    end
  end
end
