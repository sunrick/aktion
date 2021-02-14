module Aktion
  module Param
    def self.build(key, type, opts = {}, &block)
      options = options(key, type, opts)

      instance = CLASSES[options[:type]].new(options)

      instance.instance_eval(&block) if block_given?

      instance
    end

    def self.options(key, type, opts)
      type = type || :any

      {
        key: key,
        type: type,
        typer: TYPES[type],
        default: nil,
        description: nil,
        example: nil,
        notes: nil,
        children: [],
        required: false
      }.merge(opts)
    end

    class Any
      attr_accessor :key,
                    :type,
                    :typer,
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

      def required(*args, &block)
        k, type, opts = parse(args)
        opts = opts.merge(required: true)
        children << Aktion::Param.build(k, type, opts, &block)
      end

      def optional(*args, &block)
        k, type, opts = parse(args)
        children << Aktion::Param.build(k, type, opts, &block)
      end

      def parse(args)
        case args.length
        when 1
          raise 'invalid' unless type == :array
          [nil, args[0], {}]
        when 2
          [args[0], args[1], {}]
        when 3
          args
        else
          raise 'invalid'
        end
      end

      def call(k:, value:, errors:)
        value, message = typer.call(value)

        if required? && message
          errors.add(k, message)
        elsif !message && !children.empty?
          value = call_children(k: k, value: value, errors: errors)
        end

        value
      end

      def call_children(k:, value:, errors:); end
    end

    class Boolean < Any; end
    class String < Any; end
    class Integer < Any; end

    class Hash < Any
      def call_children(k:, value:, errors:)
        children.each do |child|
          child_key = "#{k}.#{child.key}"
          child_value = value[child.key]

          value[child.key] =
            child.call(k: child_key, value: child_value, errors: errors)
        end
        value
      end
    end

    class Array < Any
      def call_children(k:, value:, errors:)
        values = []
        return value if children.empty?
        children.map do |child|
          values =
            if child.key
              # child is a hash
              value.map.with_index do |hash, index|
                child_key = "#{k}.#{index}"

                message = Aktion::Types::Hash.invalid_type?(hash)
                if required? && message
                  errors.add(child_key, message)
                elsif !message
                  child_value = hash[child.key]
                  child_key = "#{child_key}.#{child.key}"
                  hash[child.key] =
                    child.call(k: child_key, value: child_value, errors: errors)
                end

                hash
              end
            else
              # child is dumb
              value.map.with_index do |child_value, index|
                child_key = "#{k}.#{index}"
                child.call(k: child_key, value: child_value, errors: errors)
              end
            end
        end

        values
      end
    end

    class Float < Any; end
    class BigDecimal < Any; end
    class Date < Any; end
    class DateTime < Any; end
    class Time < Any; end

    CLASSES = {
      any: Param::Any,
      boolean: Param::Boolean,
      string: Param::String,
      integer: Param::Integer,
      hash: Param::Hash,
      array: Param::Array,
      float: Param::Float,
      big_decimal: Param::BigDecimal,
      date: Param::Date,
      date_time: Param::DateTime,
      time: Param::Time
    }.freeze

    TYPES = {
      any: Types::Any,
      boolean: Types::Boolean,
      string: Types::String,
      integer: Types::Integer,
      hash: Types::Hash,
      array: Types::Array,
      float: Types::Float,
      big_decimal: Types::BigDecimal,
      date: Types::Date,
      date_time: Types::DateTime,
      time: Types::Time
    }.freeze
  end
end
