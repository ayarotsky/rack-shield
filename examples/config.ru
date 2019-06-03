require 'rack/shield'

# Rack::Shield.redis = Redis.new

# Rack::Shield.configure_bucket do |bucket|
# end

# Rack::Shield.configure_bucket do |bucket|
#   bucket.key = 'test_key'
#   bucket.replenish_rate = 1
#   bucket.throttled_response = lambda do |_env|
#     [403, { 'Content-Type' => 'text/plain' }, %w[Forbidden]]
#   end
# end

app = Rack::Builder.new do
  use Rack::Shield
  run ->(_env) { [200, {}, ['Hello World']] }
end

run app
