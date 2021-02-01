require 'aktion/param/base'

module Aktion
  module Param
    TYPES = {
      any: Param::Any,
      string: Param::String,
      hash: Param::Hash,
      array: Param::Array,
      integer: Param::Integer
    }

    def self.build(key, type, opts = {}, &block)
      opts = options(key, type, opts)

      instance = (TYPES[type] || TYPES[:any]).new(opts)

      instance.instance_eval(&block) if block_given?

      instance
    end

    def self.options(key, type, opts)
      {
        key: key,
        type: type || :any,
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
