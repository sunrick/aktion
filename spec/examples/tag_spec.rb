class Downcase < Aktion::Base
  request { required :tag, :string }

  def perform
    if request[:tag] == 'fail'
      failure :unprocessable_entity, { message: 'failed downcase' }
    else
      success :ok, request[:tag].downcase
    end
  end
end

class Tag < Aktion::Base
  request { required :tag, :string }

  def perform
    tag = run(Downcase).body
    success :ok, { tag: "##{tag}" }
  end
end

RSpec.describe Tag do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with valid request' do
      let(:params) { { tag: 'RoFLCopter' } }
      specify { expect(subject.response).to eq([:ok, { tag: '#roflcopter' }]) }
    end

    context 'with invalid request' do
      let(:params) { { tag: 'fail' } }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, { message: 'failed downcase' }]
        )
      end
    end
  end
end
