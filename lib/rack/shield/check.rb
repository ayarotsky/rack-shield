# frozen_string_literal: true

module Rack
  class Shield
    class Check
      def initialize(app, buckets, env)
        @app = app
        @buckets = buckets
        @request = Request.new(env)
      end

      def respond
        response = overflown? ? matching_bucket.throttled_response : @app
        response.call(@request.env)
      end

      def summary
        if matching_bucket
          status = overflown? ? :rejected : :accepted
          "Request #{status} by the bucket \"#{matching_bucket.id}\""
        else
          'No buckets match the request'
        end
      end

      private

      def overflown?
        @overflown ||= !!matching_bucket&.pour(@request)&.negative?
      end

      def matching_bucket
        return @matching_bucket if defined?(@matching_bucket)

        @matching_bucket = @buckets.find { |bucket| bucket.matches?(@request) }
      end
    end
  end
end
