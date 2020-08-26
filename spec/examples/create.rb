require 'examples/item'
require 'examples/authenticate'

class Create < Aktion::HTTP
  before Authenticate

  schema do
    required(:current_user).filled
    required(:params).hash do
      required(:name).filled(:string)
      optional(:completed_at).maybe(:date)
    end
  end

  def perform
    item = Item.new(item_params)
    if item.save
      success(:ok, item)
    else
      failure(:unprocessable_entity, item.errors)
    end
  end

  private

  def item_params
    params.slice(:name)
  end
end