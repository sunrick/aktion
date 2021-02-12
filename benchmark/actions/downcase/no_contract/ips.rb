class DowncaseAction < Aktion::Base
  def perform
    success :ok, name: request[:name].downcase
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

Benchmark.ips do |x|
  # Typical mode, runs the block as many times as it can
  x.report('class') { Downcase.perform(name: 'Rickard') }
  x.report('aktion') { DowncaseAction.perform(name: 'Rickard') }

  # Compare the iterations per second of the various reports!
  x.compare!
end
