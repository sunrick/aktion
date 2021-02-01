require 'aktion/errors'
require 'aktion/request'
require 'aktion/validations'
require 'pry'

module Aktion
  class Base
    def self.request(&block)
      if block_given?
        @request = Request.build(&block)
      else
        @request
      end
    end

    def self.validations(&block)
      if block_given?
        @validations = Validations.build(&block)
      else
        @validations
      end
    end

    def self.perform(request = {}, options = {})
      instance = new(request, options)

      self.request&.call(instance.request, instance.errors)
      self.validations&.call(instance.request, instance.errors)

      if instance.errors?
        instance.failure(:unprocessable_entity, instance.errors.to_h)
      else
        begin
          instance.perform
        rescue Aktion::PerformError => e
          instance = e.instance
        end
      end

      instance
    end

    def dependencies
      { errors: Errors }
    end

    attr_accessor :request, :options, :status, :body, :errors
    def initialize(request, options)
      self.request = request
      self.options = options
      self.errors = (options[:errors] || dependencies[:errors]).new
    end

    def perform; end

    def errors?
      errors.present?
    end

    def error(key, message)
      @failure = true
      errors.add(key, message)
    end

    def success(status, object)
      @success = true
      self.status = status
      self.body = object
    end

    def success?
      @success
    end

    def failure(status, object)
      @failure = true
      self.status = status
      self.body = object
    end

    def failure?
      @failure
    end

    def response
      [status, body]
    end

    def run(klass, payload = nil)
      instance = klass.perform(payload || request)
      instance.success? ? instance : raise_error(instance)
    end

    def raise_error(instance)
      raise Aktion::PerformError.new(instance)
    end
  end
end
