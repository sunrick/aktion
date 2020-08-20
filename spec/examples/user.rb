require 'ostruct'

class User < OpenStruct
  def self.create!(options)
    new(options)
  end

  def self.find_by(options)
    new(options)
  end
end