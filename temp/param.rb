class Param
    attr_accessor :name, :type, :checks
    def initialize(name, type)
      self.name = name
      self.type = type
    end
  
    def error(message = nil, &block)
      self.checks ||= []
      self.checks.push([message, block])    
    end
  
    def errors?(value)
      messages = []
      self.checks.each do |message, check| 
        messages.push(message) if check.call(value)
      end
      messages
    end
  end