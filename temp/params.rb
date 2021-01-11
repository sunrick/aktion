class Params
  attr_accessor :params

  def initialize
    self.params = {}
  end

  def param(name, type, &block)
    instance = Param.new(name, type)

    if !block_given?
      instance
    elsif block.arity == 0
      instance.instance_eval(&block)
    else
      yield(instance)
    end

    self.params[name.to_sym] = instance
  end

  def errors?(options)
    errors = Errors.new
    options.each do |key, value|
      param = params[key.to_sym]
      messages = param.errors?(value)
      errors.add(key.to_sym, messages ) unless messages.empty?
    end
    errors
  end
end