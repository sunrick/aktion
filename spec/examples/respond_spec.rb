require 'spec_helper'

class SimpleRespond < Aktion::Base
  request { required :name, :string }

  def perform
    respond :ok, { name: request[:name] }
  end
end

class NegativeRespond < Aktion::Base
  request { required :name, :string }

  def perform
    respond :unprocessable_entity, { message: 'sorry' }
  end
end

class BangRespond < Aktion::Base
  request { required :name, :string }

  def perform
    respond! :ok, { name: request[:name] }
    raise StandardError, 'we did not respond'
  end
end

RSpec.describe SimpleRespond do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    let(:params) { { name: 'Rickard' } }
    specify do
      expect(subject.response).to eq([:ok, { name: 'Rickard' }])
      expect(subject.success?).to eq(true)
    end
  end
end

RSpec.describe NegativeRespond do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    let(:params) { { name: 'Rickard' } }
    specify do
      expect(subject.response).to eq(
        [:unprocessable_entity, { message: 'sorry' }]
      )
      expect(subject.success?).to eq(false)
      expect(subject.failure?).to eq(true)
    end
  end
end

RSpec.describe BangRespond do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    let(:params) { { name: 'Rickard' } }
    specify do
      expect(subject.response).to eq([:ok, { name: 'Rickard' }])
      expect(subject.success?).to eq(true)
    end
  end
end
