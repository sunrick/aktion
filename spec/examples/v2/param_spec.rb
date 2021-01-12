require 'spec_helper'

RSpec.describe Aktion::V2::Param do
  context '.build' do
    context 'with only key' do
      let(:subject) { described_class.build(:name) }

      specify do
        expect(subject.key).to eq(:name)
        expect(subject.type).to eq(:any)
        expect(subject.fill).to eq(false)
        expect(subject.required).to eq(false)
        expect(subject.description).to eq(nil)
        expect(subject.example).to eq(nil)
        expect(subject.notes).to eq(nil)
        expect(subject.children).to eq([])
      end
    end

    context 'with type' do
      let(:subject) { described_class.build(:name, :string) }

      specify do
        expect(subject.key).to eq(:name)
        expect(subject.type).to eq(:string)
      end
    end

    context 'with duck typing' do
      let(:subject) { described_class.build(:name, :to_s) }

      specify do
        expect(subject.key).to eq(:name)
        expect(subject.type).to eq(:to_s)
      end
    end

    context 'with all attributes' do
      let(:subject) do
        described_class.build(
          :name,
          :string,
          fill: true,
          required: true,
          description: 'The name of the user.',
          example: 'Rickard',
          notes: 'This is a longer description.'
        )
      end

      specify do
        expect(subject.key).to eq(:name)
        expect(subject.type).to eq(:string)
        expect(subject.fill).to eq(true)
        expect(subject.required).to eq(true)
        expect(subject.description).to eq('The name of the user.')
        expect(subject.example).to eq('Rickard')
        expect(subject.notes).to eq('This is a longer description.')
      end
    end

    context 'with child param' do
      let(:subject) do
        described_class.build(:options, :hash) { param :name, :string }
      end
      let(:child) { subject.children.first }

      specify do
        expect(subject.key).to eq(:options)
        expect(subject.type).to eq(:hash)
        expect(child.key).to eq(:name)
        expect(child.type).to eq(:string)
      end
    end
  end
end
