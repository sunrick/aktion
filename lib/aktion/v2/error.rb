require 'aktion/v2/check'

module Aktion::V2
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

    def call(params)
      value = params[key]

      if method
        value.send(method) ? { key => [message] } : false
      elsif block
        check = Check.new(self, params, key, value)
        returned_error = check.instance_eval(&block)
        if check.errors?
          check.errors
        elsif returned_error
          { key => [message] }
        else
          false
        end
      else
        false
      end
    end
  end
end
