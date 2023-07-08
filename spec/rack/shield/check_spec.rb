# frozen_string_literal: true

RSpec.describe Rack::Shield::Check do
  subject { described_class.new(buckets, env) }

  let(:redis) { Rack::Shield::MockRedis.new(available_tokens: 10) }
  let(:redis_connection) { Rack::Shield::RedisConnection.new(redis) }
  let(:throttled_response) { ForbiddenResponse.new }
  let(:buckets) do
    [
      create_bucket(id: 'Test Bucket',
                    redis_connection:,
                    key: 'test_bucket',
                    replenish_rate: 10,
                    tokens: ->(req) { req.env['count'] },
                    throttled_response:,
                    filter: ->(req) { req.env['QUERY_STRING'] == 'test' })
    ]
  end
  let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 21) }

  describe '#pass?' do
    context 'no buckets match the request' do
      let(:env) { build_rack_env('QUERY_STRING' => '123', 'count' => 21) }

      it { is_expected.to be_pass }
    end

    context 'one of the buckets matches the request' do
      context 'bucket accepts request' do
        let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 2) }

        it { is_expected.to be_pass }
      end

      context 'bucket rejects request' do
        let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 11) }

        it { is_expected.not_to be_pass }
      end
    end
  end

  describe '#throttled_response' do
    context 'no buckets match the request' do
      let(:env) { build_rack_env('QUERY_STRING' => '123', 'count' => 21) }

      it { is_expected.to have_attributes(throttled_response: nil) }
    end

    context 'one of the buckets matches the request' do
      it { is_expected.to have_attributes(throttled_response:) }
    end
  end

  describe '#summary' do
    context 'check fails' do
      it { is_expected.to have_attributes(summary: 'Request rejected by bucket "Test Bucket"') }
    end

    context 'check passes' do
      context 'no buckets match the request' do
        let(:env) { build_rack_env('QUERY_STRING' => '123', 'count' => 21) }

        it { is_expected.to have_attributes(summary: 'No buckets match request') }
      end

      context 'one of the buckets matches the request' do
        context 'bucket accepts request' do
          let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 2) }

          it { is_expected.to have_attributes(summary: 'Request accepted by bucket "Test Bucket"') }
        end

        context 'bucket rejects request' do
          let(:env) { build_rack_env('QUERY_STRING' => 'test', 'count' => 11) }

          it { is_expected.to have_attributes(summary: 'Request rejected by bucket "Test Bucket"') }
        end
      end
    end
  end
end
