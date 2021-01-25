module Types
  extend self

  def types
    {
      string: Types::String,
      array: Types::Array,
      hash: Types::Hash,
      integer: Types::Integer
    }
  end

  def is_missing?(type, value)
    types[type]&.is_missing?(value)
  end

  def invalid?(type, value)
    value.nil? ? 'is missing' : types[type]&.invalid?(value)
  end

  def call(type, value)
    types[type]&.call(value)
  end

  class Base
    def self.call(value)
      if value.nil?
        [false, 'is missing']
      else

      end
    end
  end

  class String
    def self.invalid?(value)
      if value.respond_to?(:to_str)
        'is missing' if value.length == 0
      else
        'invalid type'
      end
    end
  end

  class Array
    def self.invalid?(value)
      if value.respond_to?(:to_ary)
        'is missing' if value.empty?
      else
        'invalid type'
      end
    end
  end

  class Hash
    def is_missing?(value)
      value.respond_to?(:to_hash) && value.empty?
    end

    def self.invalid?(value)
      if value.respond_to?(:to_hash)
        'is missing' if value.empty?
      else
        'invalid type'
      end
    end
  end

  class Integer
    def self.invalid?(value)
      'invalid type' unless value.respond_to?(:to_int)
    end
  end
end
