require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  context ".create" do
    it "creates a user" do
      post :create
      expect(response).to have_http_status(:ok)
    end
  end
end