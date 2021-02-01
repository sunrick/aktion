require 'aktion/check'

module Aktion
  class Error
    attr_accessor :key, :message, :method, :block

    def self.build(key = nil, message = nil, method = nil, &block)
      new(key, message, method, &block)
    end

    def initialize(key = nil, message = nil, method = nil, &block)
      self.key = key
      self.message = message
      self.method = method
      self.block = block
    end

    def value
      get(key, params)
    end

    def get(key, params)
      keys = key.to_s.split('.').map(&:to_sym)
      params.dig(*keys)
    end

    def call(params, errors)
      value = get(key, params)

      if method
        errors.add(key, message) if value.send(method)
      elsif block
        check = Check.new(self, params, errors)
        returned_error = check.instance_eval(&block)
        errors.add(key, message) if !check.message_called? && returned_error
      end
    end
  end
end
