# frozen_string_literal: true

RSpec.describe Rack::Shield::Bucket do
  let(:redis) { RedisShieldMock.new(available_tokens: 10) }
  let(:redis_connection) { Rack::Shield::RedisConnection.new(redis) }
  let(:bucket) { described_class.new(redis_connection) }
  let(:request) do
    Rack::Request.new(build_rack_env('QUERY_STRING' => 'test', 'count' => 21))
  end

  describe '#matches?' do
    let(:match) { bucket.matches?(request) }

    context 'filter is empty' do
      before { bucket.filter = nil }

      it 'matches all requests' do
        expect(match).to be true
      end
    end

    context 'filter is configured' do
      it 'matches requests that satisfy conditions' do
        bucket.filter = ->(req) { req.env['QUERY_STRING'] == 'test' }
        expect(match).to be true
      end

      it 'does not match requests that do not satisfy conditions' do
        bucket.filter = ->(req) { req.env['QUERY_STRING'] == '/' }
        expect(match).to be false
      end
    end
  end

  describe '#rejects?' do
    let(:reject) { bucket.rejects?(request) }

    context 'request takes less tokens than available in bucket' do
      it 'accepts the request' do
        expect(reject).to be false
      end
    end

    context 'request takes more tokens than available in bucket' do
      it 'rejects the request' do
        bucket.tokens = ->(req) { req.env['count'] }
        expect(reject).to be true
      end
    end
  end
end
