# frozen_string_literal: true

module Rack
  class Shield
    class Bucket
      DEFAULT_TOKENS_COUNT = 1

      attr_accessor :replenish_rate, :throttled_response, :filter, :key, :tokens

      # Initialize with redis instead of app. Raise an exception if needed
      def initialize(app)
        @app = app
      end

      def matches?(request)
        filter.nil? || filter.call(request)
      end

      def rejects?(request)
        tokens_remaining_after(request).negative?
      end

      private

      def tokens_remaining_after(request)
        @app.redis.call('shield.fb_push',
                        key_from(request),
                        replenish_rate,
                        tokens_from(request))
      end

      def key_from(request)
        key.respond_to?(:call) ? key.call(request) : key
      end

      def tokens_from(request)
        taken_tokens = tokens.respond_to?(:call) ? tokens.call(request) : tokens
        taken_tokens || DEFAULT_TOKENS_COUNT
      end
    end
  end
end
