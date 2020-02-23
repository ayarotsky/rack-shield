# frozen_string_literal: true

module Rack
  class Shield
    class Check
      def initialize(buckets, env)
        @buckets = buckets
        @request = Request.new(env)
      end

      def pass?
        @pass ||= !matching_bucket&.pour(@request)&.negative?
      end

      def throttled_response
        matching_bucket&.throttled_response
      end

      def summary
        if matching_bucket
          status = pass? ? :accepted : :rejected
          "Request #{status} by bucket \"#{matching_bucket.id}\""
        else
          'No buckets match request'
        end
      end

      private

      def matching_bucket
        return @matching_bucket if defined?(@matching_bucket)

        @matching_bucket = @buckets.find { |bucket| bucket.matches?(@request) }
      end
    end
  end
end
