require 'spec_helper'

RSpec.describe Aktion::V2::Error do
  # error = Error.build(:name, 'is missing', :nil?)
  # errors = error.call({ name: 'Rickard' })

  # error2 = Error.build(:name, 'is missing') { value.nil? }
  # errors2 = error2.call({ name: 'Rickard' })
  # errors2_1 = error2.call({ name: nil })

  # error3 = Error.build(:name) { add('is missing') if value.nil? }
  # errors3 = error3.call({ name: nil })

  # binding.pry

  shared_examples 'name tests' do
    let(:subject) { error.call(params) }

    context 'name is present' do
      let(:params) { Hash[name: 'Rickard'] }

      specify { expect(subject).to eq(false) }
    end

    context 'name is missing' do
      let(:params) { Hash[name: nil] }

      specify { expect(subject).to eq(name: 'is missing') }
    end
  end

  context 'key, message, method' do
    let(:error) { described_class.build(:name, 'is missing', :nil?) }

    include_examples 'name tests'
  end

  context 'key, message, block {}' do
    let(:error) { described_class.build(:name, 'is missing') { value.nil? } }

    include_examples 'name tests'
  end

  context 'key, message, block do+end' do
    let(:error) do
      described_class.build :name, 'is missing' do
        value.nil?
      end
    end

    include_examples 'name tests'
  end

  context 'key, block' do
    let(:error) do
      described_class.build :name do
        add('is missing') if value.nil?
      end
    end

    include_examples 'name tests'
  end

  context 'key, block, value' do
    let(:error) do
      described_class.build :name do
        add('is missing') if value.nil?
      end
    end

    include_examples 'name tests'
  end

  context 'key, block, context' do
    let(:error) do
      described_class.build :name do
        add('is missing') if context[:name].nil?
      end
    end

    include_examples 'name tests'
  end

  context 'block' do
    let(:error) do
      described_class.build { add(:name, 'is missing') if context[:name].nil? }
    end

    include_examples 'name tests'
  end
end
