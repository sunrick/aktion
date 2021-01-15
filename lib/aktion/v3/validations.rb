module Aktion::V3
  class Validations
    def self.build(&block)
      new.instance_eval(&block)
    end

    attr_accessor :nodes
    def initialize
      self.nodes = []
    end

    def call(params, errors)
      errors.each { |e| e.call(params) }
    end
  end
end
