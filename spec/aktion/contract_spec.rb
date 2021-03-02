aktion = require 'spec_helper'

RSpec.describe Aktion::Contract do
  let(:contract) do
    described_class.build do
      request do
        required :email, :string
        required :age, :integer
      end

      validations { error(:age, 'must be greater than 18') { value <= 18 } }
    end
  end

  context 'nil age' do
    let(:params) { { email: 'rickard@aktion.gem', age: nil } }

    specify do
      expect(contract.call(params)[:errors].to_h).to eq(age: ['is missing'])
    end
  end
end
