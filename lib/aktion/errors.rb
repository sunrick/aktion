module Aktion
  class Errors
    def initialize(backend: Aktion::Messages.backend)
      @backend = backend
      @store = []
    end

    def add(key, message)
      @store.push([key, message])
    end

    def merge(hash)
      hash.each { |key, value| @store.push([key, value]) }
    end

    def present?
      !@store.empty?
    end

    def to_h
      return @errors if @errors

      @errors = {}

      @store.each do |key, message|
        keys = key.to_s.split('.')
        length = keys.length

        if length > 1
          last_key = keys.pop.to_sym

          hash = { last_key => [@backend.translate(message)] }
          keys.reverse.each { |k| hash = { k.to_sym => hash } }

          deep_merge(@errors, hash)
        else
          @errors[key] ||= []
          @errors[key].push(@backend.translate(message))
        end
      end

      @errors
    end

    private

    attr_reader :store

    def deep_merge(hash, other_hash)
      hash.merge!(other_hash) do |key, this_val, other_val|
        if this_val.is_a?(Hash) && other_val.is_a?(Hash)
          deep_merge(this_val, other_val)
        else
          Array(this_val) + Array(other_val)
        end
      end
    end
  end
end
