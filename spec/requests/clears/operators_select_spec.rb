require 'rails_helper'

RSpec.describe "Clears::OperatorsSelects", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/clears/operators_select/index"
      expect(response).to have_http_status(:success)
    end
  end

end
