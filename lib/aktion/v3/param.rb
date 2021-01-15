module Aktion::V3
  class Param
    def self.build(*args, &block)
      opts =
        case args.length
        when 1
          args.is_a?(Hash) ? args : { key: args.first }
        when 2
          key, opts = args
          opts.is_a?(Hash) ? { key: key }.merge(opts) : { key: key, type: opts }
        when 3
          key, type, opts = args
          { key: key, type: type }.merge(opts)
        end

      opts = options(opts)

      instance = new(opts)

      instance.instance_eval(&block) if block_given?

      instance
    end

    def self.options(opts)
      {
        key: nil,
        type: :any,
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

    def call(value, errors); end
  end
end
