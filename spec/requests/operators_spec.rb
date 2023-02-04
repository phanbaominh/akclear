require 'rails_helper'

RSpec.describe "Operators", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/operators/show"
      expect(response).to have_http_status(:success)
    end
  end

end
