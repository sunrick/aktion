module Aktion
  class Base < Core
    class << self
      def default_args
        { headers: {}, params: {} }
      end
    end

    def params
      request[:params]
    end

    def headers
      request[:headers]
    end

    def allowed_validation_errors(errors)
      errors.slice(:params, :headers)
    end
  end
end