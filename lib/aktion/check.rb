module Aktion
  class Check
    attr_accessor :key, :value, :request, :errors

    def initialize(key, value, request, errors)
      self.key = key
      self.value = value
      self.request = request
      self.errors = errors
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
