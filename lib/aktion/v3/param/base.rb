module Aktion::V3::Param
  class Base
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

    def required(*args, &block)
      k, type, opts = parse(args)
      opts = opts.merge(required: true)
      children << Aktion::V3::Param.build(k, type, opts, &block)
    end

    def optional(*args, &block)
      k, type, opts = parse(args)
      children << Aktion::V3::Param.build(k, type, opts, &block)
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
      message = Types.invalid?(type, value)
      if required? && message
        errors.add(k, message)
        return
      elsif message
        return
      end

      call_children(k: k, value: value, errors: errors)
    end

    def call_children(k:, value:, errors:); end
  end

  class Any < Base; end
  class String < Base; end
  class Array < Base
    def call_children(k:, value:, errors:)
      children.each do |child|
        if child.key
          # child is a hash
          value.each.with_index do |child_value, index|
            child_key = "#{k}.#{index}"

            message = Types.invalid?(:hash, child_value)
            if required? && message
              errors.add(child_key, message)
              next
            elsif message
              next
            end

            child_value = child_value[child.key]
            child_key = "#{child_key}.#{child.key}"
            child.call(k: child_key, value: child_value, errors: errors)
          end
        else
          # child is dumb
          value.each.with_index do |child_value, index|
            child_key = "#{k}.#{index}"
            child.call(k: child_key, value: child_value, errors: errors)
          end
        end
      end
    end
  end

  class Hash < Base
    def call_children(k:, value:, errors:)
      children.each do |child|
        child_key = "#{k}.#{child.key}"
        child_value = value[child.key]
        child.call(k: child_key, value: child_value, errors: errors)
      end
    end
  end

  class Integer < Base; end
end
