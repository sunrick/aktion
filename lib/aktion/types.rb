module Aktion
  module Types
    class Any
      def self.invalid_type?(value)
        'is missing' if value.nil?
      end
    end

    class String
      def self.invalid_type?(value)
        if value.nil?
          'is missing'
        elsif value.respond_to?(:to_str)
          'is missing' if value.length == 0
        else
          'invalid type'
        end
      end
    end

    class Integer
      def self.invalid_type?(value)
        if value.nil?
          'is missing'
        elsif !value.respond_to?(:to_int)
          'invalid type'
        end
      end
    end

    class Hash
      def self.invalid_type?(value)
        if value.nil?
          'is missing'
        elsif value.respond_to?(:to_hash)
          'is missing' if value.empty?
        else
          'invalid type'
        end
      end
    end

    class Array
      def self.invalid_type?(value)
        if value.nil?
          'is missing'
        elsif value.respond_to?(:to_ary)
          'is missing' if value.empty?
        else
          'invalid type'
        end
      end
    end

    class Float; end

    class Decimal; end

    class Date; end

    class DateTime; end
  end
end
