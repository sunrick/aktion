require 'pry'

module Aktion::V2
  class Check
    attr_accessor :error, :params, :key, :value, :_errors, :called

    def initialize(error, params, key, value)
      self.error = error
      self.params = params
      self.key = key
      self.value = value
      self._errors = {}
    end

    def message(*params)
      self.called = true

      k, msg =
        case params.length
        when 0
          raise Errors::MissingMessage if msg.nil?
        when 1
          [key, params[0]]
        when 2
          params
        end

      raise Errors::MissingKey if k.nil?

      _errors[k] ||= []
      _errors[k] << msg
    end

    def errors
      @errors ||= process_errors
    end

    # This code is gross.
    def process_errors
      build_errors = {}

      _errors.each do |key, messages|
        keys = key.to_s.split('.')
        length = keys.length

        if length > 1
          last_key = keys.pop.to_sym

          hash = { last_key => messages }
          keys.each { |k| hash = { k.to_sym => hash } }

          deep_merge(build_errors, hash)
        else
          build_errors[key] = messages
        end
      end

      build_errors
    end

    def errors?
      called
    end

    private

    def deep_merge(hash, other_hash, &block)
      hash.merge!(other_hash) do |key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          deep_merge(this_val, other_val, &block)
        elsif block_given?
          block.call(key, this_val, other_val)
        else
          other_val
        end
      end
    end
  end
end
