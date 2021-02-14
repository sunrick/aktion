module Aktion
  class Contract
    def self.build(&block)
      instance = new
      instance.instance_eval(&block)
      instance
    end

    def request(&block)
      @request = Request.build(&block)
    end

    def validations(&block)
      @validations = Validations.build(&block)
    end

    def call(req, errors = Aktion::Errors.new)
      @request&.call(req, errors)
      @validations&.call(req, errors)

      { request: req, errors: errors }
    end

    def _request
      @request
    end

    def _validations
      @validations
    end
  end
end
