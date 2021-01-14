require 'spec_helper'

class CreateUser < Aktion::V2::Base
  param :name, :string
  param :options, :hash do
    param :age, :integer
  end

  # transform :name, :to_s

  error :name, 'is missing', :nil?
  error 'options.age', 'is less than 0' do
    value.nil? || value < 0
  end

  def perform
    success :ok, name: params[:name], age: params[:options][:age]
  end
end

RSpec.describe CreateUser do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with a valid name' do
      let(:params) { Hash[name: 'Rickard', options: { age: 12 }] }
      specify do
        expect(subject.response).to eq([:ok, name: 'Rickard', age: 12])
      end
    end

    context 'with a valid name' do
      let(:params) { Hash[name: 'Rickard', options: { age: nil }] }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, options: { age: ['is less than 0'] }]
        )
      end
    end
  end
end
