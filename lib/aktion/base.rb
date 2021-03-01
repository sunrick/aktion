require 'aktion/errors'
require 'aktion/request'
require 'aktion/validations'
require 'aktion/contract'

module Aktion
  class Base
    def self.contract(&block)
      if block_given?
        @contract = Contract.build(&block)
      else
        @contract ||= Contract.new
      end
    end

    def self.request(&block)
      contract.request(&block)
    end

    def self.validations(&block)
      contract.validations(&block)
    end

    def self.perform(request = {}, options = {})
      instance = new(request, options)

      @contract&.call(instance.request, instance.errors)

      if instance.errors?
        instance.failure(:unprocessable_entity)
      else
        begin
          instance.perform
        rescue Aktion::PerformSuccess, Aktion::PerformFailure => e
          instance = e.instance
        end
      end

      instance
    end

    attr_accessor :request, :options, :errors, :status, :body

    def initialize(request, options)
      self.request = request
      self.options = options
    end

    def perform; end

    def errors
      @errors ||= Errors.new
    end

    def errors?
      @errors&.present?
    end

    def success(status, object)
      @success = true
      self.status = status
      self.body = object
    end

    def success!(status, object)
      success(status, object)
      raise Aktion::PerformSuccess.new(self)
    end

    def success?
      @success
    end

    def failure(status, object = nil)
      @failure = true
      self.status = status
      self.body = object if object
    end

    def failure!(status, object)
      failure(status, object)
      raise Aktion::PerformFailure, self
    end

    def errors?
      errors.present?
    end

    def error(key, message)
      @failure = true
      self.status = :unprocessable_entity
      errors.add(key, message)
    end

    def error!(key, message)
      error(key, message)
      raise Aktion::PerformError, self
    end

    def respond(status = nil, object = nil, success = nil)
      self.status = status if status
      self.object = object if object
      @success = sucesss if success
      @failure = !success unless success.nil?
    end

    def respond!(status = nil, object = nil, success = nil)
      respond(status, object, success)
      raise Aktion::PerformRespond, self
    end

    def failure?
      @failure
    end

    def response
      [status, body]
    end

    def body
      errors? ? errors.to_h : @body
    end

    def run(klass, payload = nil)
      instance = klass.perform(payload || request)
      instance.success? ? instance : raise(Aktion::PerformFailure, instance)
    end
  end
end
