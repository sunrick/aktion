require 'aktion/v3/errors'
require 'aktion/v3/params'

module Aktion::V3
  class Base
    def self.params(mode = nil, &block)
      @params ||= Params.build(mode, &block)
    end

    def self.perform(params = {}, options = {})
      instance = new(params, options)

      instance.setup

      instance.pipeline.each do |item|
        if instance.errors?
          instance.failure(
            :unprocessable_entity,
            process_errors(instance.errors.to_h)
          )
        end

        break if instance.failure?

        instance.send(item)
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

    def setup
      self.class.params.map { |param| param.call(params, errors) }
    end

    attr_accessor :params, :options, :status, :body, :errors
    def initialize(params, options)
      self.params = params
      self.options = options
      self.errors = (options[:errors] || dependencies[:errors]).new
    end

    def transform; end

    def validate; end

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
      @failure == true
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
