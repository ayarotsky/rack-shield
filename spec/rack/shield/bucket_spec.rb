# frozen_string_literal: true

RSpec.describe Rack::Shield::Bucket do
  subject(:bucket) { described_class.new('Test ID', redis_connection) }

  let(:redis) { RedisShieldMock.new(available_tokens: 10) }
  let(:redis_connection) { Rack::Shield::RedisConnection.new(redis) }
  let(:request) do
    Rack::Request.new(build_rack_env('QUERY_STRING' => 'test', 'count' => 21))
  end

  describe '#id' do
    its(:id) { is_expected.to eq('Test ID') }
  end

  describe '#tokens' do
    context 'value was not set' do
      its(:tokens) { is_expected.to eq(1) }
    end

    context 'value was set' do
      it 'return the assigned value' do
        bucket.tokens = 13
        expect(bucket.tokens).to eq(13)
      end
    end
  end

  describe '#push' do
    let(:redis_connection) do
      spy(Rack::Shield::RedisConnection) # rubocop:disable RSpec/VerifiedDoubles
    end

    before do
      bucket.key = ->(req) { "test_key_for_query::#{req.env['QUERY_STRING']}" }
      bucket.tokens = ->(req) { req.env['count'] }
      bucket.replenish_rate = 10
    end

    it 'calls appropriate redis API' do
      bucket.push(request)
      expect(redis_connection)
        .to have_received(:shield_absorb)
        .with('test_key_for_query::test', 10, 21)
    end
  end

  describe '#validate!' do
    context 'replenish_rate was not set' do
      before do
        bucket.throttled_response = ForbiddenResponse.new
        bucket.key = 'test_key'
        bucket.filter = ->(_req) { true }
      end

      it 'raises an error' do
        expect { bucket.validate! }
          .to raise_error ArgumentError,
                          'Bucket#replenish_rate must be a positive number'
      end
    end

    context 'throttled_response was not set' do
      before do
        bucket.key = 'test_key'
        bucket.replenish_rate = 10
        bucket.filter = ->(_req) { true }
      end

      it 'raises an error' do
        expect { bucket.validate! }
          .to raise_error ArgumentError,
                          'Bucket#throttled_response must be a rack-compatible object ' \
                          '(https://rack.github.io)'
      end
    end

    context 'key was not set' do
      before do
        bucket.throttled_response = ForbiddenResponse.new
        bucket.replenish_rate = 10
        bucket.filter = ->(_req) { true }
      end

      it 'raises an error' do
        expect { bucket.validate! }
          .to raise_error ArgumentError,
                          'Bucket#key must be either a string or an object that responds ' \
                          'to the `call` method, taking the request object as a parameter'
      end
    end

    context 'filter was not set' do
      before do
        bucket.throttled_response = ForbiddenResponse.new
        bucket.key = 'test_key'
        bucket.replenish_rate = 10
      end

      let(:error_message) do
        'Bucket#filter must be an object that responds to the `call` method, ' \
        'taking the request object as a parameter'
      end

      it 'raises an error' do
        expect { bucket.validate! }.to raise_error ArgumentError, error_message
      end
    end

    context 'none of the attributes were set' do
      let(:error_message) do
        "Bucket#replenish_rate must be a positive number\n" \
        'Bucket#throttled_response must be a rack-compatible object ' \
        "(https://rack.github.io)\n" \
        'Bucket#key must be either a string or an object that responds ' \
        "to the `call` method, taking the request object as a parameter\n" \
        'Bucket#filter must be an object that responds to the `call` method, ' \
        'taking the request object as a parameter'
      end

      it 'raises an error' do
        expect { bucket.validate! }.to raise_error ArgumentError, error_message
      end
    end
  end
end
