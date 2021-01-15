module Aktion::V3
  class Validations
    def self.build(&block)
      new.instance_eval(&block)
    end

    attr_accessor :children
    def initialize
      self.children = []
    end

    def error(key, message, &block); end

    def call(params, errors)
      children.each { |child| child.call(params) }
    end
  end
end
