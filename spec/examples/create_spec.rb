require 'examples/create'

RSpec.describe Create do
  let(:user) { User.create!(email: 'rickard@sunden.io') }

  let(:args) do
    { headers: { email: user.email }, params: { name: 'Clean kitchen' } }
  end

  before { user }

  context '.perform' do
    context 'valid request' do
      it 'response is successful' do
        action = described_class.perform(args)
        expect(action.success?).to eq(true)
        expect(action.response).to eq(
          { json: { name: 'Clean kitchen' }, status: :ok }
        )
      end
    end

    context 'unauthenticated request' do
      let(:args) { { headers: {} } }

      it 'response is an error' do
        action = described_class.perform(args)
        expect(action.failure?).to eq(true)
        expect(action.response).to eq(
          {
            json: { errors: { headers: { email: ['is missing'] } } },
            status: :bad_request
          }
        )
      end
    end

    context 'invalid request' do
      before { allow_any_instance_of(Item).to receive(:save).and_return(false) }

      it 'response is an error' do
        action = described_class.perform(args)
        expect(action.failure?).to eq(true)
        expect(action.response).to eq(
          {
            json: { errors: { name: 'invalid' } }, status: :unprocessable_entity
          }
        )
      end
    end

    context 'bad request' do
      before { args[:params][:name] = nil }

      it 'response is an error' do
        action = described_class.perform(args)
        expect(action.failure?).to eq(true)
        expect(action.response).to eq(
          {
            json: { errors: { params: { name: ['must be filled'] } } },
            status: :bad_request
          }
        )
      end
    end
  end

  context '.new' do
    context 'no current user' do
      it 'should fail but not make current_user public' do
        action = described_class.new({})
        action.validate
        expect(action.json).to eq({ errors: { params: ['is missing'] } })
      end
    end
  end
end
