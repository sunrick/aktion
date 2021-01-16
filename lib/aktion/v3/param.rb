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
          children: []
        }.merge(opts)
      end

      attr_accessor :key,
                    :type,
                    :default,
                    :description,
                    :example,
                    :notes,
                    :children

      def initialize(opts = {})
        opts.each { |key, value| self.send("#{key}=", value) }
      end

      def get(key, params)
        keys = key.to_s.split('.').map(&:to_sym)
        params.dig(*keys)
      end

      def required(k, type, opts = {}, &block)
        children << Param::Required.build("#{key}.#{k}", type, opts, &block)
      end

      def optional(k, type, opts = {}, &block)
        children << Param::Optional.build("#{key}.#{k}", type, opts, &block)
      end

      def call(params, errors); end
    end

    class Array < Base
      def required(*args, &block)
        case args.length
        when 1
          self.children =
            Param::ArrayChild.build(key, args[0], args[1] || {}, &block)
        else
          self.children =
            Param::Required.build("#{key}.#{k}", args[1], args[2] || {}, &block)
        end
      end

      def call(params, errors)
        array = get(key, params)
        array.each_with_index do |item, index|
          children.call(params, index, item, errors)
        end
        self
      end

      # def optional(*args, &block)
      #   children << Param::Optional.build("#{key}.#{k}", type, opts, &block)
      # end
    end

    class ArrayChild < Base
      def call(params, index, item, errors)
        errors.add(key, { index => 'is not valid' })
      end
    end

    class Optional < Base
      def call(params, errors)
        children.each { |child| child.call(params, errors) }
        self
      end
    end

    class Required < Base
      def call(params, errors)
        errors.add(key, 'is missing') if get(key, params).nil?
        children.each { |child| child.call(params, errors) }
        self
      end
    end

    # class Base
    # end

    # module Array
    #   class Parent
    #   end

    #   class Child
    #   end
    # end

    # class Hash
    # end
  end
end
