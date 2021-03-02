require 'spec_helper'

RSpec.describe Aktion::Errors do
  let(:errors) { described_class.new }

  context '#add' do
    context 'single message' do
      specify do
        errors.add(:name, :missing)
        expect(errors.send(:store)).to eq(name: [:missing])
      end
    end

    context 'multiple messages' do
      specify do
        errors.add(:name, :missing)
        errors.add(:name, :ugly)
        expect(errors.send(:store)).to eq(name: %i[missing ugly])
      end
    end
  end

  context '#to_h' do
    before do
      errors.add(:age, 'too old')
      errors.add(:name, 'is missing')
      errors.add(:name, 'is ugly')
      errors.add('profile.picture', 'too small')
      errors.add('profile.picture', 'not jpeg')
    end

    specify do
      expect(errors.to_h).to eq(
        age: ['too old'],
        name: ['is missing', 'is ugly'],
        profile: { picture: ['too small', 'not jpeg'] }
      )
    end
  end
end
