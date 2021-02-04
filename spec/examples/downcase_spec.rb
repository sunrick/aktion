class Downcase < Aktion::Base
  request { required(:name, :string) }

  def perform
    success :ok, name: request[:name].downcase
  end
end

# expect(Downcase.params.get(:name))
# expect(Downcase.transformations.get(:name).call(value))
# expect(Downcase.validations.get(:name).call(value, params: params, item: item))

require 'spec_helper'

RSpec.describe Downcase do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with a valid name' do
      let(:params) { Hash[name: 'Rickard'] }
      specify { expect(subject.response).to eq([:ok, name: 'rickard']) }
    end

    context 'with an invalid name' do
      let(:params) { Hash[name: nil] }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, { name: 'is missing' }]
        )
      end
    end
  end
end