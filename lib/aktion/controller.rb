module Aktion
  module Controller
    module ClassMethods
      # aktion_class_name = self.to_s.gsub('Controller', '')
      # aktion_const = "#{aktion_class_name}::#{name.to_s.classify}".constantize

      # view_class_name = "#{aktion_class_name}_component"
      # view_const = "#{aktion_class_name}::#{view_class_name}".constantize

      def aktions(aktions)
        aktions.each do |name, options|
          klass_const = options[:action]
          view_const = options[:view]
          statuses = options[:statuses]

          define_method name do
            instance = klass_const.perform(aktion_request)
            status_handler = statuses[instance.status] if instance.failure? &&
              instance.status

            if status_handler == :raise && instance.status == :not_found
              raise ActionController::RoutingError.new('Not Found')
            end

            render view_const.new(instance.body), status: instance.status
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
