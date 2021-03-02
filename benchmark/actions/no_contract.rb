class DowncaseAction < Aktion::Base
  def perform
    respond :ok, name: request[:name].downcase
  end
end

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

Bench.perform(__FILE__) do
  ips do |x|
    x.report('class') { Downcase.perform(name: 'Rickard') }
    x.report('aktion') { DowncaseAction.perform(name: 'Rickard') }
    x.compare!
  end

  profile { DowncaseAction.perform(name: 'Rickard') }
end
