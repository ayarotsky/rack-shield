# frozen_string_literal: true

class ThrottledResponse
  def initialize(limit:)
    @limit = limit
  end

  def call(_env)
    [429, headers, body]
  end

  private

  def headers
    {
      'Content-Type' => 'text/html',
      'Retry-After' => '2'
    }
  end

  def body
    StringIO.new(<<~HTML)
      <html>
        <head>
          <title>Too Many Requests</title>
        </head>
        <body>
          <h1>Too Many Requests</h1>
          <p>I only allow <strong>#{@limit}</strong> requests per second. Try again soon.</p>
        </body>
      </html>
    HTML
  end
end
