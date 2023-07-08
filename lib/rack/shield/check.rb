# frozen_string_literal: true

module Rack
  class Shield
    class Check
      def initialize(buckets, env)
        @request = Rack::Request.new(env)
        @matching_bucket = buckets.find { _1.matches?(@request) }
      end

      def pass?
        @pass ||= !@matching_bucket&.pour(@request)&.negative?
      end

      def throttled_response
        @matching_bucket&.throttled_response
      end

      def summary
        if @matching_bucket
          "Request #{pass? ? :accepted : :rejected} by bucket \"#{@matching_bucket.id}\""
        else
          'No buckets match request'
        end
      end
    end
  end
end
