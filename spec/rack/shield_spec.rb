# frozen_string_literal: true

RSpec.describe Rack::Shield do
  after { described_class.clear_configuration }

  let(:throttled_response) { ForbiddenResponse.new }

  describe '.redis=' do
    context 'connection to a redis server with "redis-shield" module' do
      let(:connection) { Rack::Shield::MockRedis.new }

      it 'assigns the connection' do
        described_class.redis = connection
        expect(described_class.redis).to eq(connection)
      end
    end

    context 'connection to a redis server without "redis-shield" module' do
      let(:connection) { MockRedis.new }

      it 'raises an error' do
        expect { described_class.redis = connection }
          .to raise_error ArgumentError,
                          'must be a connection to redis with "redis-shield" module'
      end
    end
  end

  describe '.logger=' do
    context 'no logger was explicitly set' do
      it 'uses Rack::NullLogger' do
        expect(described_class.logger).to be_an_instance_of(Rack::NullLogger)
      end
    end

    context 'logger was explicitly set' do
      let(:logger) { Logger.new($stdout) }

      it 'uses the assigned logger' do
        described_class.logger = logger
        expect(described_class.logger).to eq(logger)
      end
    end
  end

  describe '.configure_bucket' do
    context 'redis connection was not provided' do
      let(:configuration) do
        lambda do
          described_class.configure_bucket 'Test Bucket' do |bucket|
            bucket.replenish_rate = 100
          end
        end
      end

      it 'raises an error' do
        expect { configuration.call }
          .to raise_error ArgumentError, 'redis connection is not configured'
      end
    end

    context 'redis connection was provided' do
      before { described_class.redis = Rack::Shield::MockRedis.new }

      let(:first_bucket_filter) { ->(req) { req.env['QUERY_STRING'] == '/' } }
      let(:second_bucket_filter) { ->(req) { req.env['QUERY_STRING'] == 'test' } }
      let(:buckets) { described_class.buckets }
      let(:configuration) do
        configs = []

        configs << lambda do
          described_class.configure_bucket 'Bucket 1' do |bucket|
            bucket.replenish_rate = 10
            bucket.period = 1
            bucket.tokens = 6
            bucket.key = 'test_key_1'
            bucket.throttled_response = throttled_response
            bucket.filter = first_bucket_filter
          end
        end

        configs << lambda do
          described_class.configure_bucket 'Bucket 2' do |bucket|
            bucket.replenish_rate = 12
            bucket.period = 2
            bucket.key = 'test_key_2'
            bucket.throttled_response = throttled_response
            bucket.filter = second_bucket_filter
          end
        end

        configs
      end

      # rubocop:disable RSpec/ExampleLength
      it 'creates and stores properly configured buckets' do
        expect { configuration.each(&:call) }
          .to change { described_class.buckets.size }
          .from(0)
          .to(2)

        expect(buckets.first).to have_attributes(
          replenish_rate: 10,
          period: 1,
          tokens: 6,
          key: 'test_key_1',
          filter: first_bucket_filter,
          throttled_response:
        )

        expect(buckets.last).to have_attributes(
          replenish_rate: 12,
          period: 2,
          tokens: nil,
          key: 'test_key_2',
          filter: second_bucket_filter,
          throttled_response:
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe '#call' do
    before do
      described_class.redis = redis
      described_class.logger = logger
    end

    let(:redis) { Rack::Shield::MockRedis.new(available_tokens: rate_limit) }
    let(:rate_limit) { 10 }
    let(:logger) do
      spy(Rack::NullLogger) # rubocop:disable RSpec/VerifiedDoubles
    end

    context 'no buckets were configured' do
      it 'accepts the request' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.body).to eq('Hello World')
        expect(logger).to have_received(:info).with('No buckets match request')
      end
    end

    context 'no filters match the request' do
      before do
        described_class.configure_bucket 'Test Bucket' do |bucket|
          bucket.replenish_rate = rate_limit
          bucket.period = 1
          bucket.key = 'test_bucket'
          bucket.filter = ->(req) { req.ip == '127.0.0.100' }
          bucket.throttled_response = throttled_response
        end
      end

      it 'accepts the request' do
        get '/'
        expect(last_response).to be_ok
        expect(last_response.body).to eq('Hello World')
        expect(logger).to have_received(:info).with('No buckets match request')
      end
    end

    context 'the request matches a filter' do
      before do
        described_class.configure_bucket 'Test Bucket' do |bucket|
          bucket.replenish_rate = rate_limit
          bucket.period = 1
          bucket.key = 'test_bucket'
          bucket.filter = ->(req) { req.ip == '127.0.0.1' }
          bucket.throttled_response = throttled_response
        end
      end

      context 'the rate limit was not exceeded' do
        before { get '/' }

        it 'accepts the request' do
          expect(last_response).to be_ok
          expect(last_response.body).to eq('Hello World')
        end

        it 'logs request' do
          expect(logger)
            .to have_received(:info)
            .with('Request accepted by bucket "Test Bucket"')
        end
      end

      context 'the rate limit was exceeded' do
        let(:rate_limit) { 0 }

        before { get '/' }

        it 'rejects the equest' do
          expect(last_response).to be_forbidden
          expect(last_response.body).to eq('Forbidden')
        end

        it 'logs request' do
          expect(logger)
            .to have_received(:info)
            .with('Request rejected by bucket "Test Bucket"')
        end
      end
    end

    context 'the request matches multiple filters' do
      before do
        header 'request_tokens', '19'

        described_class.configure_bucket 'Bucket 1' do |bucket|
          bucket.replenish_rate = rate_limit
          bucket.period = 1
          bucket.key = 'test_bucket'
          bucket.filter = ->(req) { req.ip == '127.0.0.1' }
          bucket.tokens = ->(req) { req.env['HTTP_REQUEST_TOKENS'] }
          bucket.throttled_response = lambda do |_env|
            [429, { 'Content-Type' => 'text/plain' }, ['Too Many Requests']]
          end
        end

        described_class.configure_bucket 'Bucket 2' do |bucket|
          bucket.replenish_rate = rate_limit
          bucket.period = 1
          bucket.key = 'test_bucket'
          bucket.filter = ->(req) { req.ip == '127.0.0.1' }
          bucket.tokens = 3
          bucket.throttled_response = throttled_response
        end

        get '/'
      end

      it 'uses the first bucket to asses the request' do
        expect(last_response.status).to eq(429)
        expect(last_response.body).to eq('Too Many Requests')
      end

      it 'logs request' do
        expect(logger)
          .to have_received(:info)
          .with('Request rejected by bucket "Bucket 1"')
      end
    end
  end
end
