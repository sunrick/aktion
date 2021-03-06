class DowncaseAction < Aktion::Base
  request { required(:name, :string) }

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
    if (message = is_not_string?(name))
      failure :unprocessable_entity, { errors: { name: [message] } }
    else
      success :ok, { name: name.downcase }
    end
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

  private

  def is_not_string?(value)
    if value.respond_to?(:to_str)
      'is missing' if value.length == 0
    else
      'invalid type'
    end
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
