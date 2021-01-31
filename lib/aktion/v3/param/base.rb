module Aktion::V3::Param
  class Any
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
      elsif !message && !children.empty?
        value = call_children(k: k, value: value, errors: errors)
      end
      value
    end

    def call_children(k:, value:, errors:); end
  end

  class String < Any; end
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

              message = Types.invalid?(:hash, hash)
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

  class Integer < Any; end
end
