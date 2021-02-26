require 'spec_helper'
require 'i18n'

RSpec.describe Aktion::Messages do
  context 'hash' do
    specify { expect(Aktion::Messages.backend).to eq(Aktion::Messages::Hash) }

    specify do
      expect(Aktion::Messages.backend.translate(:missing)).to eq('is missing')
    end

    specify do
      expect(Aktion::Messages.backend.translate(:invalid)).to eq('invalid type')
    end
  end

  context 'i18n' do
    before { Aktion::Messages.backend = :i18n }

    specify { expect(Aktion::Messages.backend).to eq(Aktion::Messages::I18n) }

    specify do
      expect(Aktion::Messages.backend.translate(:missing)).to eq('is missing')
    end

    specify do
      expect(Aktion::Messages.backend.translate(:invalid)).to eq('invalid type')
    end
  end
end
