# frozen_string_literal: true

RSpec.describe Rack::Shield::Check do
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
  let(:app) { double(Rack::Shield) }
  let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 21) }
  subject { described_class.new(app, buckets, env) }

  describe '#response' do
    context 'check fails' do
      its(:response) { is_expected.to eq(throttled_response) }
    end

    context 'check passes' do
      let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 2) }

      its(:response) { is_expected.to eq(app) }
    end
  end

  describe '#explanation' do
    context 'check fails' do
      its(:explanation) { is_expected.to eq('Request rejected by the bucket "Test Bucket"') }
    end

    context 'check passes' do
      context 'no buckets match the request' do
        let(:env) { build_rack_env('QUERY_STRING' => '123', 'count' => 21) }

        its(:explanation) { is_expected.to eq('No buckets match the request') }
      end

      context 'one of the buckets match the request' do
        let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 2) }

        its(:explanation) { is_expected.to eq('Request accepted by the bucket "Test Bucket"') }
      end
    end
  end
end
