require 'pry'
require_relative './errors.rb'
require_relative './param.rb'
require_relative './params.rb'
require_relative './response.rb'
require_relative './responses.rb'

class Aktion
  def self.params
    @@params ||= Params.new
  end

  def self.responses
    @@responses ||= Responses.new
  end

  def self.errors
    @@errors = []
  end

  def self.param(name, type, &block)
    params.param(name, type, &block)
  end

  def self.error(key = nil, message = nil, &block)
    errors << Error.build(key: key, message: message, &block)
  end

  def self.response(name, &block)
    responses.response(name, &block)
  end

  def self.perform(options = {})
    instance = new(options)

    instance.validate

    if instance.errors?
      instance.failure(:bad_request, instance.errors.to_h)
    else
      instance.perform
    end

    instance
  end

  attr_accessor :options, :status, :json, :errors

  def initialize(options = {})
    self.options = options
  end

  def params
    options
  end

  def validate
    self.errors = self.class.params.errors?(options)
  end

  def errors
    @errors ||= Errors.new
  end

  def errors?
    errors.present?
  end

  def success(status, object)
    @success = true
    self.status = status
    self.json = object
  end

  def success?
    @success || false
  end

  def failure(status, object)
    self.status = status
    self.json = object
  end

  def failure?
    !success?
  end

  def response
    { status: self.status, json: self.json }
  end
end

# example :base do
#   params {
#     name: 'Rickard'
#   }
#   response :ok, {
#     name: 'rickard'
#   }
# end

# example :base do
#   params(
#     name: 'Rickard'
#   )
#   response(
#     :ok,
#     name: 'rickard'
#   )
# end

# example :missing_name do
#   status :bad_request
#   response {
#     error: {
#       message: 'bad request'
#     }
#   }
# end

# describe Downcase do
#   context 'base' do
#     let(:example) { Downcase.example[:base] }

#     it 'should 200' do
#       expect(Downcase.perform(params: example[:params])).to eq(example[:response])
#     end
#   end
# end
