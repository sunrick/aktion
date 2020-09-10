require 'rails_helper'

RSpec.describe Aktion do
  it 'has a version number' do
    expect(Aktion::VERSION).not_to be nil
  end

  it 'works' do
    expect(Dog.name).to eq('dog')
  end
end
