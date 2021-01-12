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

  context 'with method passing' do
    let(:error) { described_class.build(:name, 'is missing', :nil?) }

    include_examples :string_presence_tests
  end

  context 'with simple blocks' do
    context '{}' do
      let(:error) { described_class.build(:name, 'is missing') { value.nil? } }

      include_examples :string_presence_tests
    end

    context 'do end' do
      let(:error) do
        described_class.build :name, 'is missing' do
          value.nil?
        end
      end

      include_examples :string_presence_tests
    end
  end

  context 'with message method' do
    context 'with value' do
      let(:error) do
        described_class.build :name do
          message('is missing') if value.nil?
        end
      end

      include_examples :string_presence_tests
    end

    context 'with context' do
      let(:error) do
        described_class.build :name do
          message('is missing') if params[:name].nil?
        end
      end

      include_examples :string_presence_tests
    end

    context 'with no key' do
      let(:error) do
        described_class.build do
          message(:name, 'is missing') if params[:name].nil?
        end
      end

      include_examples :string_presence_tests
    end

    context 'with missing key for message' do
      let(:error) do
        described_class.build { message('is missing') if value.nil? }
      end

      let(:params) { Hash[name: nil] }

      specify do
        expect { subject }.to raise_error(Aktion::V2::Errors::MissingKey)
      end
    end
  end

  context 'with multiple messages' do
    let(:error) do
      described_class.build :name do
        message('is missing') if value.nil?
        message('must be Rickard') if value != 'Rickard'
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

  context 'with multiple keys' do
  end
end
