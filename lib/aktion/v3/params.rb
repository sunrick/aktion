require 'aktion/v3/param'

module Aktion::V3
  class Params
    def self.build(mode = nil, &block)
      instance = new(mode)
      instance.instance_eval(&block)
      instance
    end

    attr_accessor :mode, :nodes
    def initialize(mode)
      self.mode = mode
      self.nodes = []
    end

    def add(key, type, opts = {}, &block)
      nodes << Param.build(key, type, opts, &block)
    end

    def required(key, type, opts = {}, &block)
      add(key, type, opts.merge(required: true), &block)
    end

    def optional(key, type, opts = {}, &block)
      add(key, type, opts, &block)
    end

    def call(params, errors)
      nodes.each { |node| node.call(params, errors) }
      self
    end
  end
end
