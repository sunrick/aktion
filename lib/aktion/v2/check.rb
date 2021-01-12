require 'pry'

module Aktion::V2
  class Check
    attr_accessor :error, :context, :key, :value, :message, :errors

    def initialize(error, context, key, value)
      self.error = error
      self.context = context
      self.key = key
      self.value = value
      self.errors = {}
    end

    def add(*params)
      k, message =
        if params.length == 1
          [key, params[0]]
        elsif params.length == 2
          params
        end

      errors[k] ||= []
      errors[k] << message
    end
  end
end
