require "dry/schema"
require "aktion/hooks"

module Aktion
  class Base
    class << self
      include Hooks

      def run(args = {})
        args = default_args.merge(args)

        failed_action = before_actions.detect do |action|
          instance = action.new(args)
          if instance.validate
            instance.perform
          else 
            break instance
          end
        end

        return failed_action if failed_action

        instance = new(args)
        if instance.validate 
          instance.perform
        else
          return instance
        end

        failed_action = after_actions.detect do |action|
          instance = action.new(args)
          if instance.validate
            instance.perform
          else 
            break instance
          end
        end

        return failed_action if failed_action

        instance
      end

      def default_args
        {}
      end

      def schema(&block)
        return @schema if instance_variable_defined?(:@schema)
        @schema = block_given? ? Dry::Schema.Params(&block) : nil
      end
    end

    attr_accessor :request
    attr_writer :json, :status

    def initialize(request)
      @request = request
    end

    def validate
      validation = self.class.schema&.call(request)
      if validation.nil? || validation.success?
        request.merge!(validation.to_h) if validation
        true
      else
        fail(:bad_request, allowed_validation_errors(validation.errors.to_h))
        false
      end
    end

    def allowed_validation_errors(errors)
      errors
    end

    def perform
    end

    def response
      { json: json, status: status }
    end

    def render
      { json: json.to_h, status: status }
    end

    def json
      @json ||= {}
    end

    def to_h
      json
    end

    def status
      @status ||= :ok
    end

    def success?
      !failure?
    end

    def failure?
      @failure || false
    end

    def errors
      self.json[:errors]
    end

    def success(json, status = nil)
      self.json = json
      self.status = status if status
    end

    def fail(status, errors = nil)
      @failure = true
      self.status = status
      self.json[:errors] = errors if errors
    end
  end
end