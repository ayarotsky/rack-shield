# frozen_string_literal: true

require 'rack/shield'
require 'logger'

require_relative 'throttled_response'

Rack::Shield.redis = Redis.new
Rack::Shield.logger = Logger.new($stdout)

Rack::Shield.configure_bucket 'rate limit by PATH_INFO' do |bucket|
  bucket.key = ->(req) { "test_key_#{req.ip}" }
  bucket.filter = ->(req) { req.env['PATH_INFO'] == '/' }
  bucket.period = 1
  bucket.replenish_rate = 4
  bucket.throttled_response = ThrottledResponse.new(limit: 4)
end

app = Rack::Builder.new do
  use Rack::Shield
  run ->(_env) { [200, {}, ['Hello World']] }
end

run app
