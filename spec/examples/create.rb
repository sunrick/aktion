require 'examples/item'
require 'examples/authenticate'

class Create < Aktion::Base
  before Authenticate

  schema do
    required(:current_user).filled
    required(:params).hash do
      required(:name).filled(:string)
      optional(:completed_at).maybe(:date)
    end
  end

  contract do
    params do
      required(:current_user).filled
      required(:params).hash do
        required(:name).filled(:string)
        option(:completed_at).maybe(:date)
      end
    end

    rules do
      rule(:current_user) do
        error('username must be rickard') if value.name != 'rickard'
      end
    end

    responses {}

    examples {}
  end

  def perform
    item = Item.new(item_params)
    item.save ? success(:ok, item) : failure(:unprocessable_entity, item.errors)
  end

  private

  def item_params
    params.slice(:name)
  end
end
