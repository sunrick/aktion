require 'aktion/check'

module Aktion
  class Error
    attr_accessor :key, :message, :method, :block, :split_key

    def self.build(key = nil, message = nil, method = nil, &block)
      new(key, message, method, &block)
    end

    def initialize(key = nil, message = nil, method = nil, &block)
      self.key = key
      self.split_key = key.to_s.split('.').map(&:to_sym)
      self.message = message
      self.method = method
      self.block = block
    end

    def call(params, errors)
      value = params.dig(*split_key)
      if method
        errors.add(key, message) if value.send(method)
      elsif block
        check = Check.new(key, value, params, errors)
        returned_error = check.instance_eval(&block)
        errors.add(key, message) if !check.message_called? && returned_error
      end
    end
  end
end
