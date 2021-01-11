require 'aktion/v2/error'

module Aktion::V2
  class Base
    def self.params
      @@params = []
    end

    def self.errors
      @@errors = []
    end

    # def self.param
    #   params << Param.build()
    # end

    def self.error(key = nil, message = nil, &block)
      errors << Error.build(key: key, message: message, &block)
    end

    def self.perform(options = {})
      instance = new(options)
      
      instance.validate

      if instance.errors?
        instance.failure(:bad_request, instance.errors.to_h)
      else
        instance.perform
      end

      instance
    end

    attr_accessor :options, :status, :json, :errors

    def initialize(options = {})
      self.options = options
    end

    def params
      options
    end

    def validate
      self.errors = self.class.params.errors?(options)
    end

    def errors
      @errors ||= Errors.new
    end

    def errors?
      errors.present?
    end

    def success(status, object)
      @success = true
      self.status = status
      self.json = object
    end

    def success?
      @success || false
    end

    def failure(status, object)
      self.status = status
      self.json = object
    end

    def failure?
      !success?
    end

    def response
      {
        status: self.status,
        json: self.json
      }
    end
  end
end