module Rack
  class Shield
    class Bucket
      DEFAULT_TOKENS_COUNT = 1
      FB_PUSH_FAILURE_RESPONSE_CODE = -1

      attr_reader :replenish_rate, :throttled_response, :filter

      def initialize(app)
        @app = app
      end

      def replenish_rate=(value)
        if value.to_i < 1
          raise ArgumentError.new('replenish_rate must be greater than 0')
        end

        @replenish_rate = value
      end

      def key=(value)
        unless callable_or?(String, value)
          raise ArgumentError.new('key must be either String or respond to #call')
        end

        @key = value
      end

      def throttled_response=(value)
        unless callable?(value)
          raise ArgumentError.new('throttled_response must respond to #call')
        end

        @throttled_response = value
      end

      def tokens=(value)
        unless callable_or?(Integer, value)
          raise ArgumentError.new('tokens must be either Integer or respond to #call')
        end

        @tokens = value
      end

      def filter=(value)
        unless callable?(value)
          raise ArgumentError.new('filter must respond to #call')
        end

        @filter = value
      end

      def matches?(request)
        @filter.nil? || filter.call(request)
      end

      def rejects?(request)
        tokens_remaining_after(request) == FB_PUSH_FAILURE_RESPONSE_CODE
      end

      private

      def callable_or?(klass, value)
        callable?(value) || value.is_a?(klass)
      end

      def callable?(value)
        value.respond_to?(:call)
      end

      def tokens_remaining_after(request)
        @app.redis.call('shield.fb_push', key(request), replenish_rate, tokens(request))
      end

      def key(request)
        @key.respond_to?(:call) ? @key.call(request) : @key
      end

      def tokens(request)
        taken_tokens = @tokens.respond_to?(:call) ? @tokens.call(self) : @tokens
        taken_tokens || DEFAULT_TOKENS_COUNT
      end
    end
  end
end
