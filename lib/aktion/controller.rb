module Aktion
  module Controller
    module ClassMethods
      def aktions(aktions = nil)
        return @aktions ||= {} if aktions.nil?

        @aktions = {}

        aktions.each do |name, options|
          options ||= {}
          @aktions[name] = { class: options[:class] || aktion_class(name) }

          define_method name do
            render_aktion(name, self.class.aktions[name])
          end
        end
      end

      def aktion_class(name)
        aktion_class_name = self.to_s.gsub('Controller', '')
        "#{aktion_class_name}::#{name.to_s.classify}".constantize
      end

      def aktion_component(name)
        aktion_class_name = self.to_s.gsub('Controller', '')
        view_class_name = "#{aktion_class_name}_component"
        "#{aktion_class_name}::#{view_class_name}".constantize
      end
    end

    def self.included(base)
      base.extend ClassMethods
      base.before_action :perform_aktion
    end

    def aktions
      @aktions
    end

    def perform_aktion
      aktion_class = self.class.aktions[params[:action].to_sym][:class]
      @aktion = aktion_class.perform(aktion_request)
    end

    def render_aktion(name, _options)
      render name, locals: aktion.body, status: aktion.status
    end

    def aktion
      @aktion
    end

    def aktion_request
      { headers: aktion_headers, params: aktion_params }
    end

    def aktion_headers
      request.headers.to_h
    end

    def aktion_params
      params.except(:controller, :action).permit!.to_h
    end
  end
end
