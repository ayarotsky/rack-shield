RSpec.describe Rack::Shield::Request do
  let(:env) { build_rack_env(requests: 10) }
  subject(:request) { described_class.new(env) }

  describe '#count' do
    context 'count was not configured' do
      its(:count) { is_expected.to eq(1) }
    end

    context 'count was configured' do
      before do
        described_class.configure do |config|
          config.count = ->(request) { request.env[:requests] }
        end
      end

      its(:count) { is_expected.to eq(10) }
    end
  end

  describe '#user_id' do
    before do
      described_class.configure do |config|
        config.user_id = ->(request) { request.ip }
      end
    end

    its(:user_id) { is_expected.to eq('127.0.0.1') }
  end
end
