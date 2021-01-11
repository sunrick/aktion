module Aktion::V2
  class Check
    attr_accessor :error, :context, :key, :value, :message

    def initialize(error, context, key, value)
      self.error = error
      self.context = context
      self.key = key
      self.value = value
    end

    def add(*params)
      if params.length == 1
        self.message = params[0]
      elsif params.length == 2
        self.key = params[0]
        self.message = params[1]
      end
    end
  end
end