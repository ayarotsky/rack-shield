# frozen_string_literal: true

RSpec.describe Rack::Shield::RedisConnection do
  describe '#initialize' do
    context 'connection to a redis server with "redis-shield" module' do
      let(:connection) { RedisShieldMock.new }

      it 'initializes a new instance' do
        expect(described_class.new(connection))
          .to be_an_instance_of(described_class)
      end
    end

    context 'connection to a redis server without "redis-shield" module' do
      let(:connection) { MockRedis.new }

      it 'raises an error' do
        expect { described_class.new(connection) }
          .to raise_error ArgumentError,
                          'must be a connection to a redis server with ' \
                          '"redis-shield" module included'
      end
    end
  end

  describe '#shield_absorb' do
    let(:connection) { spy(RedisShieldMock) } # rubocop:disable RSpec/VerifiedDoubles
    let(:redis) { described_class.new(connection) }
    let(:args) { %i[key replenish_rate tokens] }

    it 'calls appropriate redis API' do
      redis.shield_absorb(*args)
      expect(connection).to have_received(:call).with('SHIELD.absorb', *args)
    end
  end
end
