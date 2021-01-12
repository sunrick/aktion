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

    def call(context)
      value = context[key]

      if method
        value.send(method) ? { key => message } : false
      elsif block
        check = Check.new(self, context, key, value)
        is_error = check.instance_eval(&block)
        if is_error || check.message
          { key || check.key => check.message || message }
        else
          false
        end
      else
        false
      end
    end
  end
end
