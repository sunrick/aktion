require 'ostruct'

class Item < OpenStruct
  def as_json
    { name: name }
  end

  def errors
    { name: 'invalid' }
  end

  def save
    true
  end
end
