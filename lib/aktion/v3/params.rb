require 'aktion/v3/param'

module Aktion::V3
  class Params
    def self.build(&block)
      instance = new
      instance.instance_eval(&block)
      instance
    end

    attr_accessor :mode, :children
    def initialize
      self.children = []
    end

    def add(key, type, opts = {}, &block)
      opts.merge!(required: true)

      children <<
        case type
        when :hash
          Param::Hash.build(key, type, opts, &block)
        when :array
          Param::Array.build(key, type, opts, &block)
        else
          Param::Base.build(key, type, opts, &block)
        end
    end

    def call(params, errors)
      children.each { |child| child.call(params: params, errors: errors) }
      self
    end
  end
end
