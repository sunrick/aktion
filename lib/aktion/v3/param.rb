module Aktion::V3
  module Param
    class Base
      def self.build(key, type, opts = {}, &block)
        opts = options(key, name, opts)

        instance = new(opts)

        instance.instance_eval(&block) if block_given?

        instance
      end

      def self.options(key, name, opts)
        {
          key: key,
          type: name || :any,
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

      def get(key, params)
        keys = key.to_s.split('.').map(&:to_sym)
        params.dig(*keys)
      end

      def last(key)
        key.to_s.split('.').map(&:to_sym).last
      end

      def required?
        @required
      end

      def add(k, type, opts = {}, &block)
        opts.merge!(required: true)
        raise 'cannot do that'
      end

      def call(params:, errors:, item: nil, index: nil)
        if index
          k = key.gsub('%I%', index.to_s)
          errors.add(k, 'is missing') if required? && item.nil?
        else
          value = get(key, params)
          errors.add(key, 'is missing') if required? && value.nil?
        end
        self
      end
    end

    class Hash < Base
      def add(k, type, opts = {}, &block)
        opts.merge!(required: true)
        k = "#{key}.#{k}"
        children <<
          case type
          when :hash
            Param::Hash.build(k, type, opts, &block)
          when :array
            Param::Array.build(k, type, opts, &block)
          else
            Param::Base.build(k, type, opts, &block)
          end
      end

      def call(params:, errors:, item: nil, index: nil)
        if index
          k = last(key)
          value = item && item[k]
          k = key.gsub('%I%', index.to_s)
        else
          k = key
          value = get(k, params)
        end

        if required? && value.nil? || value.empty?
          errors.add(k, 'is missing')
        else
          children.each do |child|
            child.call(params: params, errors: errors, item: item, index: index)
          end
        end
        self
      end
    end

    class Array < Base
      def add(*args, &block)
        k, type, opts =
          case args.length
          when 1
            ["#{key}.%I%", args[0], {}]
          when 2
            ["#{key}.%I%.#{args[0]}", args[1], {}]
          else
            args
          end

        opts.merge!(required: true)

        children <<
          case type
          when :hash
            Param::Hash.build(k, type, opts, &block)
          when :array
            Param::Array.build(k, type, opts, &block)
          else
            Param::Base.build(k, type, opts, &block)
          end
      end

      def call(params:, errors:, item: nil, index: nil)
        items = get(key, params)

        if required? && items.nil? || items.empty?
          errors.add(key, 'is missing')
        else
          items.each.with_index do |item, index|
            children.each do |child|
              child.call(
                params: params,
                errors: errors,
                item: item,
                index: index
              )
            end
          end
        end
        self
      end
    end
  end
end
