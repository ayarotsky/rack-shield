module Rack::Shield::TestHelpers
  def app
    Rack::Builder.new do
      use Rack::Lint
      use Rack::Shield
      use Rack::Lint

      run lambda { |_env| [200, {}, ['Hello World']] }
    end
  end

  def build_rack_env(attributes = {})
    {
      'rack.version' => [1, 3],
      'rack.multithread' => true,
      'rack.multiprocess' => true,
      'rack.run_once' => false,
      'REQUEST_METHOD' => 'GET',
      'SERVER_NAME' => 'example.org',
      'SERVER_PORT' => '80',
      'QUERY_STRING' => '',
      'PATH_INFO' => '/',
      'rack.url_scheme' => 'http',
      'HTTPS' => 'off',
      'SCRIPT_NAME' => '',
      'CONTENT_LENGTH' => '0',
      'rack.test' => true,
      'REMOTE_ADDR' => '127.0.0.1',
      'HTTP_USER_ID' => '19',
      'HTTP_REQUEST_TOKENS' => '3',
      'HTTP_HOST' => 'example.org',
      'HTTP_COOKIE' => '',
      'rack.request.query_string' => '',
      'rack.request.query_hash' => {}
    }.merge(attributes)
  end
end
