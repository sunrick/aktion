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

      raise 'key' if k.nil?
      raise 'msg' if msg.nil?

      keys = k.to_s.split('.')
      length = keys.length

      if length > 1
        first_key = keys.shift.to_sym
        last_key = keys.pop.to_sym

        hash = { last_key => [msg] }
        keys.each { |k| hash = { k.to_sym => hash } }

        errors[first_key] = hash
      else
        errors[k] ||= []
        errors[k] << msg
      end
    end

    def errors?
      called
    end
  end
end
