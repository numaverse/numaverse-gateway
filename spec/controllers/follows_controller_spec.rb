require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
  context 'logged in' do
    let(:account) { create(:account) }
    before(:each) { request.session[:account_id] = account.id }

    it 'creates a follow' do
      other = create(:account_with_data)
      post :create, params: { to_account_id: other.id }
      account.from_follows.reload
      expect(account.from_follows.first).to be_present
      expect(account.from_follows.first.to_account).to eql(other)
      expect(account.from_follows.first.from_account).to eql(account)
    end
  end

  context 'logged out' do
    it 'cant view' do
      follow = create(:follow, from_account: create(:account_with_data), to_account: create(:account_with_data))
      get :show, params: { id: follow.id }
      expect(response).to redirect_to('/auth/login')
    end
  end

  it 'you cant delete someone elses follow' do
    account = create(:account)
    request.session[:account_id] = account.id
    follow = create(:follow, from_account: create(:account_with_data), to_account: create(:account_with_data))
    expect {
      delete :destroy, params: { id: follow.id }
    }.to raise_error(CanCan::AccessDenied)
  end
end
