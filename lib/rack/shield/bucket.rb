# frozen_string_literal: true

module Rack
  class Shield
    class Bucket
      DEFAULT_TOKENS_COUNT = 1
      ERROR_MESSAGES = {
        replenish_rate: 'must be a positive number',
        throttled_response: 'must be a rack-compatible object (https://rack.github.io)',
        key: 'must be either a string or an object that responds to the `call` method, ' \
             'taking the request object as a parameter',
        filter: 'must be an object that responds to the `call` method, ' \
                'taking the request object as a parameter'
      }.freeze

      attr_accessor :replenish_rate, :throttled_response, :filter, :key, :tokens
      attr_reader :id

      def initialize(id, redis)
        @id = id
        @redis = redis
      end

      def tokens
        @tokens || DEFAULT_TOKENS_COUNT
      end

      def matches?(request)
        filter.call(request)
      end

      def push(request)
        @redis.fb_push(key_from(request), replenish_rate, tokens_from(request))
      end

      def validate!
        errors = ERROR_MESSAGES.map do |attribute, error|
          "Bucket##{attribute} #{error}" unless present?(attribute)
        end.compact

        raise ArgumentError, errors.join("\n") unless errors.empty?
      end

      private

      def key_from(request)
        key.respond_to?(:call) ? key.call(request) : key
      end

      def tokens_from(request)
        tokens.respond_to?(:call) ? tokens.call(request) : tokens
      end

      def present?(attribute)
        value = public_send(attribute)
        value.respond_to?(:empty?) ? !value.empty? : !!value
      end
    end
  end
end
