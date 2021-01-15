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

    def required(key, type, opts = {}, &block)
      children << Param::Required.build(key, type, opts, &block)
    end

    def optional(key, type, opts = {}, &block)
      children << Param::Optional.build(key, type, opts, &block)
    end

    def call(params, errors)
      children.each { |node| node.call(params, errors) }
      self
    end
  end
end
