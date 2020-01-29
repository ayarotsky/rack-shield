# frozen_string_literal: true

RSpec.describe Rack::Shield::Check do
  subject { described_class.new(app, buckets, env) }

  let(:redis) { RedisShieldMock.new(available_tokens: 10) }
  let(:redis_connection) { Rack::Shield::RedisConnection.new(redis) }
  let(:throttled_response) { ForbiddenResponse.new }
  let(:buckets) do
    [
      create_bucket(id: 'Test Bucket',
                  redis_connection: redis_connection,
                  key: 'test_bucket',
                  replenish_rate: 10,
                  tokens: ->(req) { req.env['count'] },
                  throttled_response: throttled_response,
                  filter: ->(req) { req.env['QUERY_STRING'] == 'test' })
    ]
  end
  let(:app) { instance_double(Rack::Shield, call: [200, {}, ['Hello World']]) }
  let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 21) }

  describe '#respond' do
    let(:response) { subject.respond }

    context 'check fails' do
      it 'rejects request with throttled response handler' do
        expect(response)
          .to eq([403, { 'Content-Type' => 'text/plain' }, %w[Forbidden]])
      end
    end

    context 'check passes' do
      let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 2) }

      it 'passes request to the app' do
        expect(response)
          .to eq([200, {}, ['Hello World']])
      end
    end
  end

  describe '#summary' do
    context 'check fails' do
      its(:summary) { is_expected.to eq('Request rejected by the bucket "Test Bucket"') }
    end

    context 'check passes' do
      context 'no buckets match the request' do
        let(:env) { build_rack_env('QUERY_STRING' => '123', 'count' => 21) }

        its(:summary) { is_expected.to eq('No buckets match the request') }
      end

      context 'one of the buckets match the request' do
        let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 2) }

        its(:summary) { is_expected.to eq('Request accepted by the bucket "Test Bucket"') }
      end
    end
  end
end
