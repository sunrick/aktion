class DowncaseWithClassType < Aktion::Base
  request { required(:name, String) }

  readers :name

  def perform
    respond :ok, name: name.downcase
  end
end

require 'spec_helper'

RSpec.describe DowncaseWithClassType do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with a valid string' do
      let(:params) { { name: 'Rickard' } }
      specify { expect(subject.response).to eq([:ok, name: 'rickard']) }
    end

    context 'with an invalid name' do
      let(:params) { { name: 12 } }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, { name: ['invalid type'] }]
        )
      end
    end
  end
end
