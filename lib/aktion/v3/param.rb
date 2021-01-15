module Aktion::V3
  class Param
    def self.build(key, type, opts = {}, &block)
      opts = options(key, name, opts)

      instance = new(opts)

      instance.instance_eval(&block) if block_given?

      instance
    end

    def self.options(key, name, opts)
      {
        key: key,
        type: name || :any,
        default: nil,
        required: false,
        description: nil,
        example: nil,
        notes: nil,
        children: []
      }.merge(opts)
    end

    attr_accessor :key,
                  :type,
                  :required,
                  :default,
                  :description,
                  :example,
                  :notes,
                  :children

    def initialize(opts = {})
      opts.each { |key, value| self.send("#{key}=", value) }
    end

    def param(*args, &block)
      children << self.class.build(*args, &block)
    end

    def call(params, errors)
      errors.add(key, 'is missing') if required && params[key].nil?
      children.each { |child| child.call(params, errors) }
      self
    end
  end
end
