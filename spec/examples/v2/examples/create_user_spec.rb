require 'spec_helper'

class CreateUser < Aktion::V2::Base
  param :name, :string
  param :options, :hash do
    param :age, :integer
  end

  # transform :name, :to_s

  error :name, 'is missing', :nil?
  error 'options.age', 'is less than 0' do
    value.nil? || value < 0
  end

  def perform
    success :ok, name: params[:name], age: params[:options][:age]
  end
end

RSpec.describe CreateUser do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with a valid name' do
      let(:params) { Hash[name: 'Rickard', options: { age: 12 }] }
      specify do
        expect(subject.response).to eq([:ok, name: 'Rickard', age: 12])
      end
    end

    context 'with a valid name' do
      let(:params) { Hash[name: 'Rickard', options: { age: nil }] }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, options: { age: ['is less than 0'] }]
        )
      end
    end
  end
end

class Downcase
  param :name

  def transform
    map :name, :to_s
  end

  def validate
    error :name, 'is missing', :blank?
  end

  def perform
    success :ok, name: params[:name]
  end
end

class Users::Update < Aktion::Base
  params :strict do
    required(:id, :integer)
    required(:name, :string)
    required(:profile, :hash) do
      required(:age, :integer)
      required(:dogs, :array) do
        # ???
      end
    end
  end

  def authenticate; end

  def transform
    params[:name] = params[:name].upcase

    set(:name) { value.upcase }
    set(:profile, :age) { value * 10 }
    set(:profile, :dogs) { value.map(&:upcase) }
  end

  def validate
    error(:name, 'is missing') if get(:name).blank?
    error(:name, 'is missing') { value.nil? }
  end

  def load
    self.user = User.find(id: params)
  end

  def authorize
    failure(:unauthorized, 'sorry you cannot do that')
  end

  def perform
    user.update(name: params[:name])
  end
end
