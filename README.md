# Rack::Shield

![Build Status](https://github.com/ayarotsky/rack-shield/actions/workflows/code_review.yml/badge.svg?branch=main) [![codecov](https://codecov.io/gh/ayarotsky/rack-shield/branch/main/graph/badge.svg?token=X765RW7E2T)](https://codecov.io/gh/ayarotsky/rack-shield)

Rack middleware for blocking abusive requests.
It uses [redis-shield](https://github.com/ayarotsky/redis-shield) as the rate limiter.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-shield', github: 'ayarotsky/rack-shield'
```

And then execute:

    $ bundle

Configure your __rack__ application to use `rack-shield` as a middleware:

```ruby
# In config.ru

require 'rack/shield'
use Rack::Shield
```

__IMPORTANT__: `rack-shield` does nothing until you configure protection rules.
You can check out the
[configuration](https://github.com/ayarotsky/rack-shield/blob/master/examples/config.ru)
examples.

## Usage

### Redis

The gem is using `redis` as its backend. First, you need to provide a redis connection:

```ruby
Rack::Shield.redis = Redis.new
```

### Logging

By default, no information is logged. But if the logger is configured, the middleware will
output its interactions with every request.

```ruby
Rack::Shield.logger = Logger.new(STDOUT)
```

    [2020-02-25T23:03:08.340305 #70798]  INFO -- : No buckets match request
    [2020-02-25T23:03:08.148961 #70798]  INFO -- : Request accepted by bucket "rate limit by PATH_INFO"
    [2020-02-25T23:03:07.900751 #70798]  INFO -- : Request rejected by bucket "rate limit by PATH_INFO"

### Configuration

then you can take our example configuration and tailor it to your needs, or check out the advanced configuration examples.

It's possible to define as many rules as you want. Call `Rack::Shield.configure_bucket` in any file that runs when your app is being initialized. For rails apps this means creating a new file named config/initializers/rack_attack.rb and writing your rules there.

```ruby
# Configure a bucked named "rate limit by PATH_INFO"
Rack::Shield.configure_bucket 'rate limit by PATH_INFO' do |bucket|
  # A unique key used to store rule data in redis
  bucket.key = ->(req) { "test_key_#{req.ip}" }
  # A proc to test whether a request should be counted by the bucket
  bucket.filter = ->(req) { req.env['PATH_INFO'] == '/' }
  # Bucket lifetime in seconds
  bucket.period = 1
  # Number of requests allowed per period
  bucket.replenish_rate = 4
  # Rack app used to render a response when a request exceeds the limit
  bucket.throttled_response = ->(env) { [429, {'Content-Type' => 'text/plain'}, ['Too Many Requests']] }
end
```

#### `#key`

A unique key used to store bucket data in redis.

```ruby
# Can be a plain string
Rack::Shield.configure_bucket 'test' do |bucket|
  # [...]
  bucket.key = 'test_bucket'
end

# Can be a proc that accepts `Rack::Request` and returns a string
Rack::Shield.configure_bucket 'test' do |bucket|
  # [...]
  bucket.key = ->(req) { "test_key_#{req.ip}" }
end
```

#### `#filter`

A proc that accepts `Rack::Request` and returnsa truthy value that defines whether the request should
be counted by the bucket.

```ruby
Rack::Shield.configure_bucket 'test' do |bucket|
  # [...]
  bucket.filter = ->(req) { req.env['PATH_INFO'] == '/login' }
end
```

#### `#period`

Defines a period in seconds used to limit the number of requests.

#### `#replenish_rate`

Number of requests allowed per period.

#### `#throttled_response`

A [rack-compatible](https://rack.github.io) object used to render a response when a
request exceeds the limit.

It can be a simple proc that acceppts
[rack environment](https://rubydoc.info/github/rack/rack/master/file/SPEC) and returns
an array of exactly three values: **status**, **headers**, and **body**:

```ruby
Rack::Shield.configure_bucket 'test' do |bucket|
  # [...]
  bucket.throttled_response = ->(env) { [429, {'Content-Type' => 'text/plain'}, ['Too Many Requests']]
end
```

Or it can be a Plain Old Ruby Object that contains some complex logic, as shown in
[examples](https://github.com/ayarotsky/rack-shield/blob/master/examples/throttled_response.rb).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run rubocop and tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
