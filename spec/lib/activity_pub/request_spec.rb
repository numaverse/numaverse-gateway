require 'rails_helper'

describe ActivityPub::Request do

  # These tests were ran against a local Mastodon instance.
  describe 'Signing requests' do
    let(:federated_account) { real_federated_account }
    let(:remote_account) { Federated::Account.from_remote_id("http://localhost:3000/users/admin")}


    it 'signs outgoing messages', :vcr do
      request = ActivityPub::Request.new(remote_account.object_data['inbox'], 
        from_account: federated_account, 
        verb: :post,
        body: '{"a": 1}',
      )        
      response = request.perform
      expect(request.success?).to eql(true)
    end
  end
end