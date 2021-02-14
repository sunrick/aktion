require 'aktion/check'

module Aktion
  module Error
    def self.build(key = nil, message = nil, method = nil, &block)
      if method
        Method.new(key, message, method)
      else
        Block.new(key, message, &block)
      end
    end

    class Method
      attr_accessor :key, :message, :method, :split_key

      def initialize(key, message, method)
        self.key = key
        self.split_key = key.to_s.split('.').map(&:to_sym)
        self.message = message
        self.method = method
        self.block = block
      end

      def call(params, errors)
        value = params.dig(*split_key)
        errors.add(key, message) if value.send(method)
      end
    end

    class Block
      attr_accessor :key, :message, :block, :split_key

      def initialize(key = nil, message = nil, &block)
        self.key = key
        self.split_key = key.to_s.split('.').map(&:to_sym)
        self.message = message
        self.block = block
      end

      def call(params, errors)
        value = params.dig(*split_key)
        check = Check.new(key, value, params, errors)
        returned_error = check.instance_eval(&block)
        errors.add(key, message) if !check.message_called? && returned_error
      end
    end
  end
end
