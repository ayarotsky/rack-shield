class RedisShieldMock
  FX_PUSH_FAILURE_RESPONSE = -1
  FX_PUSH_COMMAND = 'shield.fx_push'

  def initialize(available_tokens:)
    @available_tokens = available_tokens
  end

  def call(command, key, limit, tokens)
    raise ArgumentError.new('Unknown command') if command.downcase != FX_PUSH_COMMAND
    diff = @available_tokens - tokens
    return FX_PUSH_FAILURE_RESPONSE if diff < 0
    @available_tokens = diff
  end
end
