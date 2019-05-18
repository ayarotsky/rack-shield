RSpec.describe Rack::Shield::Configurable do
  class DummyTestClass
    include Rack::Shield::Configurable

    config_accessor :one
  end

  subject(:dummy_object) { DummyTestClass.new }

  it 'saves the value of accessor after an update' do
    expect { dummy_object.config.one = 3 }
      .to change { dummy_object.config.one }
      .from(nil)
      .to(3)
  end

  it 'does not respond to undefined accessors' do
    expect { dummy_object.config.two }.to raise_error(NoMethodError)
  end

  describe '.configure' do
    before do
      DummyTestClass.configure do |config|
        config.one = 'test config'
      end
    end

    it 'properly sets assigned values' do
      expect(dummy_object.config.one).to eq('test config')
    end
  end
end
