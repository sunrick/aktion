module Aktion
  module Controller
    module ClassMethods
      def aktions(aktions)
        aktions.each do |aktion|
          klass_name = self.to_s.gsub('Controller', '')
          klass_const = "#{klass_name}::#{aktion.to_s.classify}".constantize
    
          define_method aktion do
            render klass_const.perform(aktion_request).response
          end
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  
    def aktion_request
      {
        headers: aktion_headers,
        params: aktion_params
      }
    end
    
    def aktion_headers
      request.headers.to_h
    end
  
    def aktion_params
      params.permit!.to_h
    end
  end
end