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

  def invalid?(type, value)
    types[type]&.invalid?(value)
  end

  class String
    def self.invalid?(value)
      'is missing' if value.is_a?(String) && value.length > 0
    end
  end
end
