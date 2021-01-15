class Downcase < Aktion::V3::Base
  params { required :name, :string }

  def perform
    success :ok, name: params[:name].downcase
  end
end

require 'spec_helper'

RSpec.describe Downcase do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with a valid name' do
      let(:params) { Hash[name: 'Rickard'] }
      specify { expect(subject.response).to eq([:ok, name: 'rickard']) }
    end
  end
end
