module Aktion::V3
  class Errors
    attr_accessor :errors

    def initialize
      self.errors = {}
    end

    def add(key, message)
      self.errors[key] = message
    end

    def present?
      !errors.empty?
    end

    def to_h
      errors
    end
  end
end
