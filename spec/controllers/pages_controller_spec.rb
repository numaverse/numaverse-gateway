require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  describe "GET #home" do
    it "returns http success" do
      get :home
      expect(response).to have_http_status(:success)
    end

    it "redirects to federated account search with the right pattern", :vcr do
      query = "@hstove@mastodon.social"
      get :home, params: { query: query }
      account = assigns(:account)
      expect(response).to redirect_to(search_federated_accounts_path(handle: query))
    end
  end

end
