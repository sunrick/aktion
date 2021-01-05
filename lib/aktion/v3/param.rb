module Aktion::V3
  class Param
    def self.build(key, type, opts = {}, &block)
      opts = options(key, type, opts)

      instance = new(opts)

      instance.instance_eval(&block) if block_given?

      instance
    end

    def self.options(key, type, opts)
      {
        key: key,
        type: type || :any,
        default: nil,
        description: nil,
        example: nil,
        notes: nil,
        children: [],
        required: false
      }.merge(opts)
    end

    attr_accessor :key,
                  :type,
                  :default,
                  :description,
                  :example,
                  :notes,
                  :children,
                  :required

    def initialize(opts = {})
      opts.each { |key, value| self.send("#{key}=", value) }
    end

    def required?
      @required
    end

    def required(k, type, opts = {}, &block)
      opts.merge!(required: true)
      add(k, type, opts, &block)
    end

    def optional(k, type, opts = {}, &block)
      add(k, type, opts, &block)
    end

    def add(k, type, opts = {}, &block)
      children << self.class.build(k, type, opts, &block)
    end

    def call(k:, value:, errors:)
      case type
      when :hash
        if value.nil? || value.empty?
          errors.add(k, 'is missing') if required?
          return
        end
      when :array
        if value.nil? || value.empty?
          errors.add(k, 'is missing') if required?
          return
        end
      else
        if value.nil?
          errors.add(k, 'is missing') if required?
          return
        end
      end

      children.each do |child|
        case type
        when :hash
          child_key = "#{k}.#{child.key}"
          child_value = value[child.key] if child.key
          child.call(k: child_key, value: child_value, errors: errors)
        when :array
          value.each.with_index do |child_value, index|
            child_key = "#{k}.#{index}"

            if required? && (child_value.nil? || child_value.empty?)
              errors.add(child_key, 'is missing')
            elsif !(child_value.nil? || child_value.empty?)
              child_value = child_value[child.key] if child.key
              child_key = "#{child_key}.#{child.key}" if child.key
              child.call(k: child_key, value: child_value, errors: errors)
            end
          end
        end
      end
    end
  end
end
