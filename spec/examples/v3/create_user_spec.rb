# class CreateUser < Aktion::V3::Base
#   params do
#     required :name, :string
#     required :profile, :hash do
#       required :age, :integer
#       optional :weight, :integer
#     end
#   end
#   def validate
#     error(:name, 'cannot have numbers') if params[:name].match(/\d\)
#     error(:profile, :age, 'must be over 18') if params[:profile][:name] < 18
#     error([:profile, :age], 'must be over 18') { value < 18 }
#   end
#   def perform
#     user = User.new(params)
#     if user.save
#       success :ok, user
#     else
#       failure :unprocessable_entity, user.errors.messages
#     end
#   end
# end
# require 'spec_helper'
# RSpec.describe Downcase do
#   let(:subject) { described_class.perform(params) }
#   context '.perform' do
#     context 'with a valid name' do
#       let(:params) { Hash[name: 'Rickard'] }
#       specify { expect(subject.response).to eq([:ok, name: 'rickard']) }
#     end
#     context 'with an invalid name' do
#       let(:params) { Hash[name: nil] }
#       specify do
#         expect(subject.response).to eq(
#           [:unprocessable_entity, { name: 'is missing' }],
#         )
#       end
#     end
#   end
# end
