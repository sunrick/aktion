require "ostruct"
require "pry"

class User < OpenStruct
  def self.create!(options)
    new(options)
  end
end

class Item < OpenStruct
  def as_json
    { name: name }
  end

  def errors
    { name: 'invalid' }
  end

  def save
    true
  end
end

class Create < Aktion::Base
  schema do
    required(:params).hash do
      required(:name).filled(:string)
      optional(:completed_at).maybe(:date)
    end
  end

  def perform
    item = Item.new(item_params)
    if item.save
      success(item)
    else
      fail(:unprocessable_entity, item.errors)
    end
  end

  private

  def item_params
    params.slice(:name)
  end
end

RSpec.describe Create do
  let(:user) { User.create!(email: 'rickard@sunden.io') }

  let(:args) do
    {
      params: { name: 'Clean kitchen' }
    }
  end

  before do
    user
  end

  context '.run' do
    context 'valid request' do
      it 'response is successful' do
        action = described_class.run(args)
        expect(action.success?).to eq(true)
        expect(action.render).to eq({
          json: {
            name: 'Clean kitchen'
          },
          status: :ok
        })
      end
    end

    # context 'unauthenticated request' do
    #   let(:args) { { headers: {} } }

    #   it 'response is an error' do
    #     action = described_class.run(args)
    #     expect(action.failure?).to eq(true)
    #     expect(action.render).to eq({
    #       json: {
    #         "errors" =>  {
    #           "headers" => {
    #             "email"=> ["is missing"]
    #           }
    #         }
    #       },
    #       status: :bad_request
    #     })
    #   end
    # end

    context 'invalid request' do
      before do
        allow_any_instance_of(Item).to receive(:save).and_return(false)
      end

      it 'response is an error' do
        action = described_class.run(args)
        expect(action.failure?).to eq(true)
        expect(action.render).to eq({
          json: {
            :errors =>  {
              :name => 'invalid'
            }
          },
          status: :unprocessable_entity
        })
      end
    end

    context 'bad request' do
      before do
        args[:params][:name] = nil
      end

      it 'response is an error' do
        action = described_class.run(args)
        expect(action.failure?).to eq(true)
        expect(action.render).to eq({
          json: {
            :errors =>  {
              :params => {
                :name => ["must be filled"]
              }
            }
          },
          status: :bad_request
        })
      end
    end
  end
end