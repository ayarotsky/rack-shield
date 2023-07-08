# frozen_string_literal: true

class RedisShieldMock
  FAILURE_RESPONSE = -1
  SUPPORTED_COMMANDS = %w[shield.absorb].freeze
  DEFAULT_TOKENS = 1

  def initialize(available_tokens: 0)
    @available_tokens = available_tokens
  end

  def call(*args)
    command = args[0].downcase
    raise ArgumentError, 'Unknown redis command' unless SUPPORTED_COMMANDS.include?(command)

    __send__("#{command.tr('.', '_')}_redis_command", *args[1..])
  end

  def module(*_args)
    [['name', 'SHIELD', 'ver', 1]]
  end

  private

  # SHIELD.absorb <key>, <limit>, <period>, <tokens>
  def shield_absorb_redis_command(*args)
    tokens = (args[3] || DEFAULT_TOKENS).to_i
    diff = @available_tokens - tokens
    return FAILURE_RESPONSE if diff.negative?

    @available_tokens = diff
  end
end
