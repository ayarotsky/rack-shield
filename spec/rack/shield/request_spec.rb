RSpec.describe Rack::Shield::Request do
  let(:env) { {requests: 10, user: 'test'} }
  subject(:request) { described_class.new(env) }

  describe '#count' do
    context 'count was not configured' do
      its(:count) { is_expected.to eq(1) }
    end

    context 'count was configured' do
      around do |example|
        described_class.configure do |config|
          config.count = ->(env) { env[:requests] }
        end

        example.run

        described_class.configure do |config|
          config.count = nil
        end
      end

      its(:count) { is_expected.to eq(10) }
    end
  end

  describe '#user_id' do
    before do
      described_class.configure do |config|
        config.user_id = ->(env) { env[:user] * 2 }
      end
    end

    its(:user_id) { is_expected.to eq('testtest') }
  end
end
