require 'spec_helper'

RSpec.describe Aktion::V2::Error do
  let(:subject) { error.call(params) }

  shared_examples :string_presence_tests do
    context 'name is present' do
      let(:params) { Hash[name: 'Rickard'] }

      specify { expect(subject).to eq(false) }
    end

    context 'name is missing' do
      let(:params) { Hash[name: nil] }

      specify { expect(subject).to eq(name: ['is missing']) }
    end
  end

  context 'key, message, method' do
    let(:error) { described_class.build(:name, 'is missing', :nil?) }

    include_examples :string_presence_tests
  end

  context 'key, message, block {}' do
    let(:error) { described_class.build(:name, 'is missing') { value.nil? } }

    include_examples :string_presence_tests
  end

  context 'key, message, block do+end' do
    let(:error) do
      described_class.build :name, 'is missing' do
        value.nil?
      end
    end

    include_examples :string_presence_tests
  end

  context 'key, block' do
    let(:error) do
      described_class.build :name do
        add('is missing') if value.nil?
      end
    end

    include_examples :string_presence_tests
  end

  context 'key, block, value' do
    let(:error) do
      described_class.build :name do
        add('is missing') if value.nil?
      end
    end

    include_examples :string_presence_tests
  end

  context 'key, block, context' do
    let(:error) do
      described_class.build :name do
        add('is missing') if context[:name].nil?
      end
    end

    include_examples :string_presence_tests
  end

  context 'block' do
    let(:error) do
      described_class.build { add(:name, 'is missing') if context[:name].nil? }
    end

    include_examples :string_presence_tests
  end

  context 'key, multiple messages, block' do
    let(:error) do
      described_class.build :name do
        add('is missing') if value.nil?
        add('must be Rickard') if value != 'Rickard'
      end
    end

    context 'name is valid' do
      let(:params) { Hash[name: 'Rickard'] }

      specify { expect(subject).to eq(false) }
    end

    context 'name is invalid' do
      let(:params) { Hash[name: 'John'] }

      specify { expect(subject).to eq(name: ['must be Rickard']) }
    end

    context 'name is missing' do
      let(:params) { Hash[name: nil] }

      specify { expect(subject).to eq(name: ['is missing', 'must be Rickard']) }
    end
  end

  context 'multiple keys, single message, block' do
  end

  context 'block, missing key for add(message)' do
    let(:error) { described_class.build { add('is missing') if value.nil? } }

    let(:params) { Hash[name: nil] }

    specify do
      expect { subject }.to raise_error(Aktion::V2::Errors::MissingKey)
    end
  end
end
