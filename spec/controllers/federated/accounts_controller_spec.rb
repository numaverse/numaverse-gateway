require 'rails_helper'

RSpec.describe Federated::AccountsController, type: :controller do

  describe "GET #search" do
    let(:host) { Addressable::URI.parse(Rails.application.routes.url_helpers.root_url).host }

    it "finds an account", :vcr do
      get :search, params: { handle: "@hstove@mastodon.social" }
      account = assigns(:account)
      expect(account).to be_a(Federated::Account)
      expect(account.federated_id).to eql('https://mastodon.social/users/hstove')
      expect(response).to redirect_to(federated_account_path(account))
    end

    it 'redirects when local account' do
      account = create(:account, username: 'testertester')
      get :search, params: { handle: "@testertester@#{host}"}
      expect(response).to redirect_to(account_path(account))
    end

    it 'redirects with error when not found', :vcr do
      get :search, params: { handle: "@asfsdafsdsdsfdfasfsdafasdfsad@mastodon.social" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).not_to be_blank
    end

    it 'redirects when local user not found' do
      get :search, params: { handle: "@#{SecureRandom.hex(12)}@#{host}" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).not_to be_blank
    end
  end

end
