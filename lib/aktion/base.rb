require 'aktion/errors'
require 'aktion/request'
require 'aktion/validations'

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
        instance.perform
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
      [self.status, self.body]
    end
  end
end
