require 'spec_helper'

class Downcase < Aktion::V2::Base
  contract MyContract

  param :name, :string

  # transform :name, :to_s

  error :name do
    if value.nil?
      message 'is missing'
    elsif value.match(/\d/)
      message 'cannot have numbers'
    end
  end

  # response :ok do
  #   field :name
  # end

  # example :base do
  #   params name: 'Rickard'
  #   response :ok do
  #     { name: 'rickard' }
  #   end
  # end

  def perform
    success :ok, name: params[:name].downcase
  end
end

RSpec.describe Downcase do
  let(:subject) { described_class.perform(params) }

  context '.perform' do
    context 'with a valid name' do
      let(:params) { Hash[name: 'Rickard'] }
      specify { expect(subject.response).to eq([:ok, name: 'rickard']) }
    end

    context 'with a missing name key' do
      let(:params) { Hash[name: nil] }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, name: ['is missing']]
        )
      end
    end

    context 'with a nil name' do
      let(:params) { Hash[name: nil] }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, name: ['is missing']]
        )
      end
    end

    context 'with a invalid name' do
      let(:params) { Hash[name: 'Rickard13'] }
      specify do
        expect(subject.response).to eq(
          [:unprocessable_entity, name: ['cannot have numbers']]
        )
      end
    end
  end
end
