# frozen_string_literal: true

module Rack
  class Shield
    class Bucket
      ERROR_MESSAGES = {
        replenish_rate: 'must be a positive number',
        period: 'must be a positive number',
        throttled_response: 'must be a rack-compatible object',
        key: 'must be either a string or an object that responds to the `call` method, ' \
             'taking the request object as a parameter',
        filter: 'must be an object that responds to the `call` method, ' \
                'taking the request object as a parameter'
      }.freeze

      attr_reader :id
      attr_accessor :replenish_rate, :period, :throttled_response, :filter, :key, :tokens

      def initialize(id, redis)
        @id = id
        @redis = redis
      end

      def matches?(request)
        filter.call(request)
      end

      def pour(request)
        @redis.shield_absorb(key_from(request),
                             replenish_rate,
                             period,
                             tokens_from(request))
      end

      def validate!
        errors = ERROR_MESSAGES.filter_map do |attribute, error|
          "#{attribute} #{error}" unless present?(attribute)
        end

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
