require 'spec_helper'
require 'i18n'

RSpec.describe Aktion::Messages do
  context 'default' do
  end

  context 'i18n' do
    before { Aktion::Messages.backend = I18n }
  end
end
