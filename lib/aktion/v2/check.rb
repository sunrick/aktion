require 'pry'

module Aktion::V2
  class Check
    attr_accessor :error, :params, :key, :value, :errors, :called

    def initialize(error, params, key, value)
      self.error = error
      self.params = params
      self.key = key
      self.value = value
      self.errors = {}
    end

    def message(*params)
      self.called = true

      k, msg =
        case params.length
        when 0
          raise Errors::MissingMessage if msg.nil?
        when 1
          [key, params[0]]
        when 2
          params
        end

      raise Errors::MissingKey if k.nil?

      errors[k] ||= []
      errors[k] << msg
    end

    def errors?
      called
    end
  end
end
