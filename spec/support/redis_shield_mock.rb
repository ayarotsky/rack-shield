class RedisShieldMock
  FX_PUSH_FAILURE_RESPONSE = -1
  SUPPORTED_COMMANDS = %w[shield.fx_push module]

  def initialize(available_tokens:)
    @available_tokens = available_tokens
  end

  def call(*args)
    command = args[0].downcase
    raise ArgumentError.new('Unknown redis command') unless SUPPORTED_COMMANDS.include?(command)
    __send__("#{command.gsub('.', '_')}_redis_command", args[1..-1])
  end

  private

  # SHIELD.FX_PUSH <key>, <limit>, <tokens>
  def shield_fx_push_redis_command(*args)
    diff = @available_tokens - args[2]
    return FX_PUSH_FAILURE_RESPONSE if diff < 0
    @available_tokens = diff
  end
end
