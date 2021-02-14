require 'aktion/param/any'

module Aktion
  module Param
    CLASSES = {
      any: Param::Any,
      string: Param::String,
      hash: Param::Hash,
      array: Param::Array,
      integer: Param::Integer
    }

    TYPES = {
      any: Types::Any,
      string: Types::String,
      hash: Types::Hash,
      array: Types::Array,
      integer: Types::Integer
    }

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
        validator: TYPES[type],
        default: nil,
        description: nil,
        example: nil,
        notes: nil,
        children: [],
        required: false
      }.merge(opts)
    end
  end
end
