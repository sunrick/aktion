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
      children << Param.build(key, type, opts, &block)
    end

    def call(params, errors)
      children.each do |child|
        child.call(k: child.key, value: params[child.key], errors: errors)
      end
      self
    end
  end
end
