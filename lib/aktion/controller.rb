module Aktion
  module Controller
    module ClassMethods
      def aktions(aktions)
        aktions.each do |aktion|
          aktion_class_name = self.to_s.gsub('Controller', '')
          aktion_const =
            "#{aktion_class_name}::#{aktion.to_s.classify}".constantize

          view_class_name = "#{aktion_class_name}_component"
          view_const = "#{aktion_class_name}::#{view_class_name}".constantize

          define_method aktion do
            klass_const.perform(aktion_request)
            render view_const.new(aktion.body), status: aktion.status
          end
        end
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def aktion_request
      { headers: aktion_headers, params: aktion_params }
    end

    def aktion_headers
      request.headers.to_h
    end

    def aktion_params
      params.slice(:controller, :action).permit!.to_h
    end
  end
end
