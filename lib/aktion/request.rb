require 'aktion/param'

module Aktion
  class Request
    def self.build(&block)
      instance = new
      instance.instance_eval(&block)
      instance
    end

    attr_accessor :mode, :children
    def initialize
      self.children = []
    end

    def required(*args, &block)
      k, type, opts = parse(args)
      validate(k, type, opts)

      opts = opts.merge(required: true)
      children << Param.build(k, type, opts, &block)
    end

    def optional(*args, &block)
      k, type, opts = parse(args)
      validate(k, type, opts)

      children << Param.build(k, type, opts, &block)
    end

    def parse(args)
      case args.length
      when 1
        [nil, args[0], {}]
      when 2
        [args[0], args[1], {}]
      when 3
        args
      else
        raise 'invalid'
      end
    end

    def validate(key, type, opts)
      raise 'key must be present' if key.nil? && type != :array
      raise 'type must be present' if type.nil?
      raise 'opts must be present' if opts.nil?
    end

    def call(params, errors = Aktion::Errors.new)
      children.each do |child|
        params[child.key] =
          child.call(k: child.key, value: params[child.key], errors: errors)
      end

      { params: params, errors: errors }
    end
  end
end
