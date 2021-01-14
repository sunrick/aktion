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
      keys = key.to_s.split('.').map(&:to_sym)
      value = keys.length > 1 ? params.dig(*keys) : params[key]

      if method
        value.send(method) ? { key => [message] } : false
      elsif block
        check = Check.new(self, params, key, value)
        returned_error = check.instance_eval(&block)
        if check.errors?
          process_errors(check.errors)
        elsif returned_error
          process_errors({ key => [message] })
        else
          false
        end
      else
        false
      end
    end

    private

    # This code is gross.
    def process_errors(errors)
      build_errors = {}

      errors.each do |key, messages|
        keys = key.to_s.split('.')
        length = keys.length

        if length > 1
          last_key = keys.pop.to_sym

          hash = { last_key => messages }
          keys.each { |k| hash = { k.to_sym => hash } }

          Utils.deep_merge(build_errors, hash)
        else
          build_errors[key] = messages
        end
      end

      build_errors
    end
  end
end
