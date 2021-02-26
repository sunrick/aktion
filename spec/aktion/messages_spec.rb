require 'spec_helper'
require 'i18n'

# I18n.load_path << Dir[File.expand_path('config/locales') + '/*.yml']
# I18n.default_locale = :en # (note that `en` is already the default!)

RSpec.describe Aktion::Messages do
  context 'default' do
  end

  context 'i18n' do
    before { Aktion::Messages.backend = :i18n }

    specify do
      expect(Aktion::Messages.backend.translate(:missing)).to eq('is missing')
    end
  end
end
