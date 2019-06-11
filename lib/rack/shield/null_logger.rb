# frozen_string_literal: true

module Rack
  class Shield
    class NullLogger
      def info(_message)
      end

      def warn(_message)
      end

      def error(_message)
      end
    end
  end
end
