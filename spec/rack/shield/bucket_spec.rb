RSpec.describe Rack::Shield::Bucket do
  let(:app) { double(redis: RedisShieldMock.new(available_tokens: 10)) }
  let(:bucket) { described_class.new(app) }
  let(:proc_value) { -> { 2 ** 2 } }
  let(:callable_value) do
    Class.new do
      def self.call
      end
    end
  end

  describe '#replenish_rate' do
    context 'value is less than 1' do
      it 'raises an error' do
        expect { bucket.replenish_rate = 0 }
          .to raise_error(ArgumentError, 'replenish_rate must be greater than 0')
      end
    end

    context 'value is a string' do
      it 'raises an error' do
        expect { bucket.replenish_rate = 'test' }
          .to raise_error(ArgumentError, 'replenish_rate must be greater than 0')
      end
    end

    context 'value is a float' do
      it 'assigns the integer part' do
        expect { bucket.replenish_rate = 12.12 }
          .to change { bucket.replenish_rate }
          .from(nil)
          .to(12)
      end
    end

    context 'value is a positive integer' do
      it 'assigns the integer part' do
        expect { bucket.replenish_rate = 13 }
          .to change { bucket.replenish_rate }
          .from(nil)
          .to(13)
      end
    end
  end

  describe '#key' do
    context 'value is a string' do
      it 'assigns the string' do
        expect { bucket.key = 'test' }
          .to change { bucket.key }
          .from(nil)
          .to('test')
      end
    end

    context 'value is nil' do
      it 'raises an error' do
        expect { bucket.key = nil }
          .to raise_error(ArgumentError, 'key must be either String or respond to #call')
      end
    end

    context 'value is a proc' do
      it 'assigns the proc' do
        expect { bucket.key = proc_value }
          .to change { bucket.key }
          .from(nil)
          .to(proc_value)
      end
    end

    context 'value is an object that responds to #call' do
      it 'assigns the object' do
        expect { bucket.key = callable_value }
          .to change { bucket.key }
          .from(nil)
          .to(callable_value)
      end
    end
  end

  describe '#throttled_response' do
    context 'value is a string' do
      it 'raises an error' do
        expect { bucket.throttled_response = 'test' }
          .to raise_error(ArgumentError, 'throttled_response must respond to #call')
      end
    end

    context 'value is nil' do
      it 'raises an error' do
        expect { bucket.throttled_response = nil }
          .to raise_error(ArgumentError, 'throttled_response must respond to #call')
      end
    end

    context 'value is a proc' do
      it 'assigns the proc' do
        expect { bucket.throttled_response = proc_value }
          .to change { bucket.throttled_response }
          .from(nil)
          .to(proc_value)
      end
    end

    context 'value is an object that responds to #call' do
      it 'assigns the object' do
        expect { bucket.throttled_response = callable_value }
          .to change { bucket.throttled_response }
          .from(nil)
          .to(callable_value)
      end
    end
  end

  describe '#tokens' do
    context 'value is an integer' do
      it 'assigns the integer' do
        expect { bucket.tokens = 11 }
          .to change { bucket.tokens }
          .from(nil)
          .to(11)
      end
    end

    context 'value is a float' do
      it 'raises an error' do
        expect { bucket.tokens = 12.12 }
          .to raise_error(ArgumentError, 'tokens must be either Integer or respond to #call')
      end
    end

    context 'value is nil' do
      it 'raises an error' do
        expect { bucket.tokens = nil }
          .to raise_error(ArgumentError, 'tokens must be either Integer or respond to #call')
      end
    end

    context 'value is a proc' do
      it 'assigns the proc' do
        expect { bucket.tokens = proc_value }
          .to change { bucket.tokens }
          .from(nil)
          .to(proc_value)
      end
    end

    context 'value is an object that responds to #call' do
      it 'assigns the object' do
        expect { bucket.tokens = callable_value }
          .to change { bucket.tokens }
          .from(nil)
          .to(callable_value)
      end
    end
  end

  describe '#filter' do
    context 'value is a string' do
      it 'raises an error' do
        expect { bucket.filter = 'test' }
          .to raise_error(ArgumentError, 'filter must respond to #call')
      end
    end

    context 'value is nil' do
      it 'raises an error' do
        expect { bucket.filter = nil }
          .to raise_error(ArgumentError, 'filter must respond to #call')
      end
    end

    context 'value is a proc' do
      it 'assigns the proc' do
        expect { bucket.filter = proc_value }
          .to change { bucket.filter }
          .from(nil)
          .to(proc_value)
      end
    end

    context 'value is an object that responds to #call' do
      it 'assigns the object' do
        expect { bucket.filter = callable_value }
          .to change { bucket.filter }
          .from(nil)
          .to(callable_value)
      end
    end
  end
end
