require 'pry'

class Error
  attr_accessor :key, :message, :method, :block

  def self.build(key = nil, message = nil, method = nil, &block)
    new(key, message, method, &block)
  end

  def initialize(key = nil, message = nil, method = nil, &block)
    self.key = key
    self.message = message
    self.method = method
    self.block = block
  end

  def call(context)
    value = context[key]

    if method
      if value.send(method)
        { key => message }
      else
        false
      end
    elsif block
      check = Check.new(self, context, value)
      is_error = check.instance_eval(&block)
      if is_error || check.message
        { key => check.message || message }
      else
        false
      end
    else
      false
    end
  end
end

class Check
  attr_accessor :error, :context, :value, :message

  def initialize(error, context, value)
    self.error = error
    self.context = context
    self.value = value
  end

  def add(string)
    self.message = string
  end
end

# def param(name, type, &block)
#   instance = Param.new(name, type)

#   if !block_given?
#     instance
#   elsif block.arity == 0
#     instance.instance_eval(&block)
#   else
#     yield(instance)
#   end

#   self.params[name.to_sym] = instance
# end

error = Error.build(:name, 'is missing', :nil?)
errors = error.call({ name: 'Rickard' })

error2 = Error.build(:name, 'is missing') { value.nil? }
errors2 = error2.call({ name: 'Rickard' })
errors2_1 = error2.call({ name: nil })

error3 = Error.build(:name) { add('is missing') if value.nil? }
errors3 = error3.call({ name: nil })

binding.pry