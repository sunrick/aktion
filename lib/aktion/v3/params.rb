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

    def add(*args, &block)
      nodes << Param.build(*args, &block)
    end

    def required(*args, &block)
      add(*args, &block)
    end

    def optional(*args, &block)
      add(*args, &block)
    end

    def call(params, errors)
      nodes.each { |node| node.call(params, errors) }
      self
    end
  end
end
