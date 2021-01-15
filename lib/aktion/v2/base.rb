require 'aktion/v2/utils'
require 'aktion/v2/error'
require 'aktion/v2/param'

module Aktion::V2
  class Base
    def self.params
      @params ||= []
    end

    def self.errors
      @errors ||= []
    end

    def self.param(*args, &block)
      params << Param.build(*args, &block)
    end

    def self.error(*args, &block)
      errors << Error.build(*args, &block)
    end

    def self.perform(options = {})
      instance = new(options)

      instance.transform
      instance.validate

      if instance.errors?
        instance.failure(:unprocessable_entity, instance.errors.to_h)
      else
        instance.perform
      end

      instance
    end

    attr_accessor :options, :params, :status, :body, :errors

    def initialize(options = {})
      self.options = options
      self.params = options
      self.errors = {}
    end

    def transform
      params.each do |key, original_value|
        status, value = find_param(key)&.call(original_value)
        if status == :ok
          params[key] = value
        elsif !status.nil?
          raise 'implement me'
        end
      end
    end

    def find_param(key)
      self.class.params.detect { |p| p.key == key }
    end

    def validate
      results =
        self.class.errors.map { |error| error.call(params) }.select { |e| e }

      results.each { |r| Utils.deep_merge(errors, r) }
    end

    def errors?
      !errors.empty?
    end

    def success(status, object)
      @success = true
      self.status = status
      self.body = object
    end

    def success?
      @success || false
    end

    def failure(status, object)
      self.status = status
      self.body = object
    end

    def failure?
      !success?
    end

    def response
      [self.status, self.body]
    end
  end
end
