# frozen_string_literal: true

class ForbiddenResponse
  def call(_env)
    [403, { 'Content-Type' => 'text/plain' }, %w(Forbidden)]
  end
end
