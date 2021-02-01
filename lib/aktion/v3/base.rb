require 'aktion/v3/errors'
require 'aktion/v3/params'
require 'aktion/v3/validations'

module Aktion::V3
  class Base
    def self.params(&block)
      if block_given?
        @params = Params.build(&block)
      else
        @params
      end
    end

    def self.validations(&block)
      if block_given?
        @validations = Validations.build(&block)
      else
        @validations
      end
    end

    def self.perform(params = {}, options = {})
      instance = new(params, options)

      self.params&.call(instance.params, instance.errors)
      self.validations&.call(instance.params, instance.errors)

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

    attr_accessor :params, :options, :status, :body, :errors
    def initialize(params, options)
      self.params = params
      self.options = options
      self.errors = (options[:errors] || dependencies[:errors]).new
    end

    def perform
      raise NotImplementedError
    end

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
