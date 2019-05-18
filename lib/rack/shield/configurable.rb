module Rack
  class Shield
    module Configurable
      def self.included(base)
        base.extend ClassMethods
      end

      def config
        @config ||= self.class.config
      end

      module ClassMethods
        def config
          @config ||= configuration_class.new
        end

        def configure
          yield config
        end

        private

        def config_accessor(*attributes)
          configuration_class.class_eval do
            attr_accessor *attributes
          end
        end

        def configuration_class
          @configuration_class ||= Class.new
        end
      end
    end
  end
end
