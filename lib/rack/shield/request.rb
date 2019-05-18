module Rack
  class Shield
    class Request < Rack::Request
      include Configurable

      DEFAULT_COUNT = 1

      config_accessor :user_id, :count

      def count
        return DEFAULT_COUNT unless config.count
        config.count.call(env)
      end

      def user_id
        config.user_id.call(env)
      end
    end
  end
end
