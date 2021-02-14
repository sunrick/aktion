require 'aktion/error'

module Aktion
  class Validations
    def self.build(&block)
      instance = new
      instance.instance_eval(&block)
      instance
    end

    attr_accessor :children
    def initialize
      self.children = []
    end

    def error(key = nil, message = nil, method = nil, &block)
      children << Error.build(key, message, method, &block)
    end

    def call(params, errors)
      param_errors = errors.errors.dup

      children.each do |child|
        next if param_errors[child.key]
        child.call(params, errors)
      end
    end
  end
end
