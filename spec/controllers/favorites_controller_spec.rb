require 'rails_helper'

RSpec.describe FavoritesController, type: :controller do
  context 'logged out' do
    it 'blocks creating favorites' do
      post :create
      expect(response).to redirect_to('/auth/login')
    end
  end

  context 'logged in' do
    let(:account) { create(:account) }
    before(:each) { request.session[:account_id] = account.id }
    it 'creates a favorite' do
      message = create(:message)
      post :create, params: { message_id: message.id, format: :json }
      message.reload
      expect(message.favorites.count).to eql(1)
      expect(message.favorites_count).to eql(1)
      expect(message.favorites.first.account).to eql(account)
    end
  end
end
