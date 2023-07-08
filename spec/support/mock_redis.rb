# frozen_string_literal: true

class MockRedis
  def module(*_args)
    []
  end
end

# Refinement for MockRedis that adds methods to interact with redis shield module
module Rack
  class Shield
    class MockRedis < MockRedis
      def initialize(*args, available_tokens: 10)
        super(*args)
        @available_tokens = available_tokens
      end

      def call(*args, &)
        command = args.shift

        if command == 'SHIELD.absorb'
          shield_absorb_command(*args)
        else
          super(command, &)
        end
      end

      def module(*_args)
        [['name', 'SHIELD', 'ver', 1]]
      end

      private

      # SHIELD.absorb <key>, <limit>, <period>, <tokens>
      def shield_absorb_command(*args)
        tokens = (args[3] || 1).to_i
        diff = @available_tokens - tokens
        return -1 if diff.negative?

        @available_tokens = diff
      end
    end
  end
end
