class Upcase < Aktion::Base
  request { required :tag, :string }

  def perform
    if request[:tag] == 'fail'
      respond :unprocessable_entity, { message: 'failed upcase' }
    else
      respond :ok, request[:tag].upcase
    end
  end
end

class Tag < Aktion::Base
  request { required :tag, :string }

  def perform
    tag = run(Upcase).body
    respond :ok, { tag: "##{tag}" }
  end
end

RSpec.describe Tag do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with valid request' do
      let(:params) { { tag: 'RoFLCopter' } }
      specify { expect(subject.response).to eq([:ok, { tag: '#ROFLCOPTER' }]) }
    end

    context 'with invalid request' do
      let(:params) { { tag: 'fail' } }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, { message: 'failed upcase' }]
        )
      end
    end
  end
end
