module Aktion
  class Errors
    attr_accessor :errors

    def initialize(backend: Aktion::Messages::Backend)
      @backend = backend
      @errors = {}
    end

    def [](key)
      @errors[key]
    end

    def add(key, message)
      @errors[key] = @backend.translate(message)
    end

    def present?
      !@errors.empty?
    end

    def to_h
      build_errors = {}

      @errors.each do |key, messages|
        keys = key.to_s.split('.')
        length = keys.length

        if length > 1
          last_key = keys.pop.to_sym

          hash = { last_key => messages }
          keys.reverse.each { |k| hash = { k.to_sym => hash } }

          deep_merge(build_errors, hash)
        else
          build_errors[key] = messages
        end
      end

      build_errors
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
