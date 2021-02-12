class Downcase
  def self.perform(*args)
    new(*args).perform
  end

  attr_accessor :name, :body, :status

  def initialize(name:)
    self.name = name
  end

  def perform
    success :ok, { name: name.downcase }
  end

  def success(status, object)
    @success = true
    self.body = object
    self.status = :ok
  end

  def success?
    @success
  end

  def failure
    @failure = true
    self.body = object
    self.status = :ok
  end

  def failure?
    @failure
  end
end
