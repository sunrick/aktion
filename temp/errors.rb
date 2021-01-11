class Errors
  attr_accessor :hash

  def initialize(hash = {})
    self.hash = hash
  end

  def add(key, error)
    hash[key] ||= []
    hash[key].push(error)
  end

  def present?
    !hash.empty?
  end

  def empty?
    hash.empty?
  end

  def to_h
    hash
  end
end
  