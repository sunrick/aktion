require 'bigdecimal'
require 'date'
require 'time'

module Aktion
  module Types
    MISSING = :missing
    INVALID = :invalid
    NIL = nil.freeze

    class Any
      def self.empty_string?(value); end

      def self.call(value)
        if value.nil? || (value.respond_to?(:to_str) && value.length == 0)
          [value, MISSING]
        else
          [value, NIL]
        end
      end
    end

    class Single
      def self.call(value, type)
        if value.nil? || (value.respond_to?(:to_str) && value.length == 0)
          [value, MISSING]
        elsif !value.is_a?(type)
          [value, INVALID]
        else
          [value, NIL]
        end
      end
    end

    class Boolean
      BOOLEANS = {
        '1' => true,
        'on' => true,
        'On' => true,
        'ON' => true,
        't' => true,
        'true' => true,
        'True' => true,
        'TRUE' => true,
        'T' => true,
        'y' => true,
        'yes' => true,
        'Yes' => true,
        'YES' => true,
        'Y' => true,
        true => true,
        '0' => false,
        'off' => false,
        'Off' => false,
        'OFF' => false,
        'f' => false,
        'false' => false,
        'False' => false,
        'FALSE' => false,
        'F' => false,
        'n' => false,
        'no' => false,
        'No' => false,
        'NO' => false,
        'N' => false,
        false => false
      }.freeze

      def self.call(value)
        if value.nil?
          [value, MISSING]
        else
          bool = BOOLEANS[value]
          bool.nil? ? [value, INVALID] : [bool, NIL]
        end
      end
    end

    class String
      def self.call(value)
        message =
          if value.nil?
            MISSING
          elsif value.respond_to?(:to_str)
            MISSING if value.length == 0
          else
            INVALID
          end
        [value, message]
      end
    end

    class Integer
      def self.call(value)
        if value.nil?
          [value, MISSING]
        elsif value.respond_to?(:to_int)
          [Integer(value), NIL]
        elsif value.respond_to?(:to_str)
          value.length == 0 ? [value, MISSING] : [Integer(value, 10), NIL]
        else
          [value, INVALID]
        end
      rescue ArgumentError, TypeError
        [value, INVALID]
      end
    end

    class Hash
      def self.call(value)
        message =
          if value.nil?
            MISSING
          elsif value.respond_to?(:to_hash)
            MISSING if value.empty?
          else
            INVALID
          end
        [value, message]
      end
    end

    class Array
      def self.call(value)
        message =
          if value.nil?
            MISSING
          elsif value.respond_to?(:to_ary)
            MISSING if value.empty?
          else
            INVALID
          end
        [value, message]
      end
    end

    class Float
      def self.call(value)
        if value.nil?
          [value, MISSING]
        elsif value.respond_to?(:to_int)
          [Float(value), NIL]
        elsif value.respond_to?(:to_str)
          value.length == 0 ? [value, MISSING] : [Float(value), NIL]
        else
          [value, INVALID]
        end
      rescue ArgumentError, TypeError
        [value, INVALID]
      end
    end

    class BigDecimal
      def self.call(value)
        if value.nil?
          [value, MISSING]
        elsif value.respond_to?(:to_int)
          [Float(value).to_d, NIL]
        elsif value.respond_to?(:to_str)
          value.length == 0 ? [value, MISSING] : [Float(value).to_d, NIL]
        else
          [value, INVALID]
        end
      rescue ArgumentError, TypeError
        [value, INVALID]
      end
    end

    class Date
      def self.call(value)
        if value.nil?
          [value, MISSING]
        elsif value.respond_to?(:to_str) && value.length == 0
          [value, MISSING]
        elsif value.respond_to?(:to_date)
          [value.to_date, NIL]
        else
          [value, INVALID]
        end
      rescue ArgumentError, TypeError, RangeError => e
        [value, INVALID]
      end
    end

    class DateTime
      def self.call(value)
        if value.nil?
          [value, MISSING]
        elsif value.respond_to?(:to_str)
          value.length == 0 ? [value, MISSING] : [::DateTime.parse(value), NIL]
        elsif value.respond_to?(:to_datetime)
          [value.to_datetime, NIL]
        else
          [value, INVALID]
        end
      rescue ArgumentError, TypeError => e
        [value, INVALID]
      end
    end

    class Time
      def self.call(value)
        if value.nil?
          [value, MISSING]
        elsif value.respond_to?(:to_str)
          value.length == 0 ? [value, MISSING] : [::Time.parse(value), NIL]
        elsif value.respond_to?(:to_time)
          [value.to_time, NIL]
        else
          [value, INVALID]
        end
      rescue ArgumentError, TypeError => e
        [value, INVALID]
      end
    end
  end
end
