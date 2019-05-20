RSpec.describe Rack::Shield do
  before do
    header 'request_tokens', tokens_per_request.to_s

    Rack::Shield::Request.configure do |config|
      config.user_id = ->(request) { request.ip }
      config.count = ->(request) { request.env['HTTP_REQUEST_TOKENS'] }
    end

    Rack::Shield.configure do |config|
      config.rate_limit = rate_limit
      config.redis = RedisShieldMock.new(available_tokens: rate_limit)
      config.rejected_response = ForbiddenResponse.new
    end
  end

  let(:rate_limit) { 10 }

  context 'rate limit was not exceeded' do
    let(:tokens_per_request) { 3 }

    it 'accepts requests' do
      get '/'
      expect(last_response).to be_ok
    end
  end

  context 'rate limit was exceeded' do
    let(:tokens_per_request) { 11 }

    it 'rejects requests' do
      get '/'
      expect(last_response.status).to eq(403)
    end
  end
end
