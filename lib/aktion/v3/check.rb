module Aktion::V3
  class Check
    attr_accessor :parent, :params, :key, :value, :errors

    def initialize(parent, params, errors)
      self.parent = parent
      self.params = params
      self.errors = errors
    end

    def key
      parent.key
    end

    def value
      get(key, params)
    end

    def get(key, params)
      keys = key.to_s.split('.').map(&:to_sym)
      params.dig(*keys)
    end

    def message(*args)
      @message_called = true

      k, msg =
        case args.length
        when 0
          raise Errors::MissingMessage if msg.nil?
        when 1
          [key, args[0]]
        when 2
          args
        end

      raise Errors::MissingKey if k.nil?

      errors.add(k, msg)
    end

    def message_called?
      @message_called
    end
  end
end
