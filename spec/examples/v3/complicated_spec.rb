class Complicated < Aktion::V3::Base
  params do
    add :name, :string

    add :profile, :hash do
      add :age, :integer
      # add :hobbies, :array
    end

    add :dog_names, :array

    # add :dogs, :array do
    #   add :name, :string
    # end
  end

  # validations { error(:name, 'is missing') { value.nil? } }

  def perform
    success :ok, params
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

RSpec.describe Aktion::V3::Params do
  let(:errors) { Aktion::V3::Errors.new }
  before { builder.call(params, errors) }

  context 'something' do
    let(:builder) do
      described_class.build do
        add :dogs, :array do
          add :string
        end
      end
    end
    let(:params) { { dogs: [nil] } }

    specify { expect(errors.to_h).to eq(dogs: { '0': 'is missing' }) }
  end

  context 'something' do
    let(:builder) do
      described_class.build do
        add :dogs, :array do
          add :name, :string
        end
      end
    end
    let(:params) { { dogs: [nil] } }

    specify { expect(errors.to_h).to eq(dogs: { '0': { name: 'is missing' } }) }
  end

  context 'something' do
    let(:builder) do
      described_class.build do
        add :dogs, :array do
          add :name, :string
          add :chicken, :hash do
            add :name, :string
            add :hobbies, :array
          end
        end
      end
    end
    let(:params) { { dogs: [nil] } }

    specify do
      expect(errors.to_h).to eq(
        dogs: { "0": { chicken: 'is missing', name: 'is missing' } }
      )
    end
  end
end
