# frozen_string_literal: true

require 'rack/shield'

Rack::Shield.redis = Redis.new

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
          <p>I only allow #{@limit} requests per second. Try again soon.</p>
        </body>
      </html>
    HTML
  end
end

Rack::Shield.configure_bucket do |bucket|
  bucket.key = ->(req) { "test_key_#{req.ip}" }
  bucket.filter = ->(req) { req.env['PATH_INFO'] == '/' }
  bucket.replenish_rate = 4
  bucket.throttled_response = ThrottledResponse.new(limit: 4)
end

app = Rack::Builder.new do
  use Rack::Shield
  run ->(_env) { [200, {}, ['Hello World']] }
end

run app
