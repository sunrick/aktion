require 'aktion/v3/errors'
require 'aktion/v3/params'
require 'aktion/v3/validations'

module Aktion::V3
  class Base
    def self.params(mode = nil, &block)
      if block_given?
        @params = Params.build(mode, &block)
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
        instance.failure(
          :unprocessable_entity,
          instance.process_errors(instance.errors.to_h)
        )
      else
        instance.perform
      end

      instance
    end

    def process_errors(errors)
      errors
    end

    def dependencies
      { errors: Errors }
    end

    def pipeline
      %i[transform validate perform]
    end

    attr_accessor :params, :options, :status, :body, :errors
    def initialize(params, options)
      self.params = params
      self.options = options
      self.errors = (options[:errors] || dependencies[:errors]).new
    end

    def perform; end

    def errors?
      errors.present?
    end

    def error(key, message, &block)
      if block_given?
        # errors.build(key, message).instance_eval(&block)
      else
        errors.add(key, message)
      end
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
