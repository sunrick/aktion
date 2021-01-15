require 'aktion/v3/param'

module Aktion::V3
  class Params
    def self.build(mode = nil, &block)
      new(mode).instance_eval(&block)
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
  end
end
