# frozen_string_literal: true

class RedisShieldMock
  FX_PUSH_FAILURE_RESPONSE = -1
  SUPPORTED_COMMANDS = %w[shield.fb_push module].freeze

  def initialize(available_tokens:)
    @available_tokens = available_tokens
  end

  def call(*args)
    command = args[0].downcase
    unless SUPPORTED_COMMANDS.include?(command)
      raise ArgumentError, 'Unknown redis command'
    end
    __send__("#{command.tr('.', '_')}_redis_command", *args[1..-1])
  end

  private

  # SHIELD.FX_PUSH <key>, <limit>, <tokens>
  def shield_fb_push_redis_command(*args)
    diff = @available_tokens - args[2]
    return FX_PUSH_FAILURE_RESPONSE if diff < 0
    @available_tokens = diff
  end
end
