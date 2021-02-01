module Aktion
  class Rails < Base
    def self.perform(request, options = {})
      request = { headers: {}, params: {} }.merge(request)
      super(request, options)
    end

    def params
      request[:params]
    end

    def headers
      request[:headers]
    end

    def response
      { status: status, body: body }
    end

    # def allowed_validation_errors(errors)
    #   errors.slice(:params, :headers)
    # end
  end
end
