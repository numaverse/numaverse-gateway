require 'rails_helper'

RSpec.describe Federated::FollowsController, type: :controller do
  let(:federated_account) { create(:federated_account) }
  let(:account) { federated_account.local_account }

  before { sign_in_account(account) }

  describe "POST #create" do
    let(:to_account) { create(:remote_account) }
    it "returns http success" do
      post :create, params: { to_account_id: to_account.id }
      expect(response).to have_http_status(:redirect)
      expect(Federated::Follow.find_by(to_account: to_account, from_account: account.federated_account)).to be_present
    end
  end

  describe "DELETE #destroy" do
    let(:follow) { create(:federated_follow, from_account: federated_account) }
    it "returns http success" do
      delete :destroy, params: { id: follow.id }
      expect { follow.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to have_http_status(:redirect)
    end
  end

end
