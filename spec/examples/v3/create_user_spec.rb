class User
  attr_accessor :name, :profile
  def initialize(name:, profile: {})
    self.name = name
    self.profile = profile
  end

  def to_h
    { name: name, profile: profile }
  end

  def save
    true
  end
end

class CreateUser < Aktion::V3::Base
  params do
    required :name, :string
    required :profile, :hash do
      required :age, :integer
      optional :weight, :integer
    end
  end

  validations do
    # error(:name, 'only non-digits allowed') { value.match(/\d/) }
    error(:name) { message 'only non-digits allowed' if value.match(/\d/) }
  end

  def perform
    user = User.new(params)
    if user.save
      success :ok, user.to_h
    else
      failure :unprocessable_entity, user.errors.messages
    end
  end
end

require 'spec_helper'

RSpec.describe CreateUser do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with valid request' do
      let(:params) { Hash[name: 'Rickard', profile: { age: 30 }] }
      specify do
        expect(subject.response).to eq(
          [:ok, { name: 'Rickard', profile: { age: 30 } }]
        )
      end
    end

    context 'with name that has numbers' do
      let(:params) { Hash[name: 'Rickard13', profile: { age: 30 }] }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, { name: 'only non-digits allowed' }]
        )
      end
    end
  end
end
