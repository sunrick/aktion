require 'spec_helper'
require 'i18n'

RSpec.describe Aktion::Messages do
  context 'default' do
  end

  context 'i18n' do
    before { Aktion::Messages.backend = :i18n }

    specify do
      expect(Aktion::Messages.backend).to eq(Aktion::Messages::I18n)
      expect(Aktion::Messages.backend.translate(:missing)).to eq('is missing')
    end
  end
end
