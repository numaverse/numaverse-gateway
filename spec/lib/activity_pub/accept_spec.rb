require 'rails_helper'

describe ActivityPub::Accept do
  context 'follows' do
    let(:account) { create(:transacted_account) }
    let(:federated_account) { account.reload.federated_account }
    let(:from_local_account) { create(:transacted_account) }
    let(:from_account) { from_local_account.update_federated_model }
    let(:remote_account) { create(:remote_account) }
    let!(:federated_follow) { create(:federated_follow, from_account: from_account, to_account: federated_account) }
    let!(:remote_follow) { create(:federated_follow, from_account: remote_account, to_account: federated_account) }
    let(:activity) { ActivityPub::Accept.new(remote_follow) }
    let(:data) { activity.hashie_data }

    it 'creates an accept object' do
      expect(data.object.actor).to eql(remote_account.url_id)
      expect(data.object.type).to eql('Follow')
      expect(data.type).to eql('Accept')
    end
  end
end