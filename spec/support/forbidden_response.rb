class ForbiddenResponse
  def call(env)
    [403, { 'Content-Type' => 'text/plain' }, %w[Forbidden]]
  end
end
