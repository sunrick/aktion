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
        if params.length == 1
          [key, params[0]]
        elsif params.length == 2
          params
        end

      errors[k] ||= []
      errors[k] << msg
    end

    def errors?
      called
    end
  end
end
