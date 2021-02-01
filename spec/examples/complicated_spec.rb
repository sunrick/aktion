class Complicated < Aktion::Base
  request do
    required :name, :string

    required :profile, :hash do
      required :age, :integer
      # required :hobbies, :array
    end

    required :dog_names, :array

    # required :dogs, :array do
    #   required :name, :string
    # end
  end

  # validations { error(:name, 'is missing') { value.nil? } }

  def perform
    success :ok, request
  end
end

require 'spec_helper'

RSpec.describe Complicated do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with a valid request' do
      let(:params) do
        Hash[
          name: 'Rickard',
          profile: { age: 30, hobbies: [:soccer] },
          dog_names: ['bjorn'],
          dogs: [{ name: 'Bjorn' }]
        ]
      end
      specify do
        expect(subject.response).to eq(
          [
            :ok,
            name: 'Rickard',
            profile: { age: 30, hobbies: [:soccer] },
            dog_names: ['bjorn'],
            dogs: [{ name: 'Bjorn' }]
          ]
        )
      end
    end

    context 'with a invalid request' do
      let(:params) { Hash[name: nil, profile: {}] }
      specify do
        expect(subject.response).to eq(
          [
            :unprocessable_entity,
            {
              name: 'is missing',
              profile: 'is missing',
              dog_names: 'is missing'
            }
          ]
        )
      end
    end

    context 'with a invalid request' do
      let(:params) { Hash[name: nil, profile: { age: nil }] }
      specify do
        expect(subject.response).to eq(
          [
            :unprocessable_entity,
            {
              name: 'is missing',
              profile: { age: 'is missing' },
              dog_names: 'is missing'
            }
          ]
        )
      end
    end
  end
end
