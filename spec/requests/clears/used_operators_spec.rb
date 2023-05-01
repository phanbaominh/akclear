require 'rails_helper'

RSpec.describe "Clears::UsedOperators", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/clears/used_operators/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/clears/used_operators/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
