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
  end
end
