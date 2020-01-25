# frozen_string_literal: true

module Rack
  class Shield
    class Check
      def initialize(app, buckets, env)
        @app = app
        @buckets = buckets
        @request = Request.new(env)
      end

      def response
        fails? ? matching_bucket.throttled_response : @app
      end

      def explanation
        if matching_bucket
          "Request #{request_status} by the bucket \"#{matching_bucket.id}\""
        else
          'No buckets match the request'
        end
      end

      private

      def request_status
        fails? ? :rejected : :accepted
      end

      def fails?
        @fails ||= begin
          remaining_tokens = matching_bucket&.push(@request)
          !!remaining_tokens&.negative?
        end
      end

      def matching_bucket
        return @matching_bucket if defined?(@matching_bucket)

        @matching_bucket = @buckets.find { |bucket| bucket.matches?(@request) }
      end
    end
  end
end
