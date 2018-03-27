require 'rails_helper'

RSpec.describe Federated::Version, type: :model do
  describe 'deliver!' do
    let(:message) { create(:message, account: local_federated_account.local_account) }
    let(:federated_message) { message.update_federated_model }
    let(:local_federated_account) { real_federated_account }
    let(:remote_account) { Federated::Account.from_remote_id("http://localhost:3000/users/admin") }
    let(:federated_follow) { create(:federated_follow, from_account: remote_account, to_account: local_federated_account) }

    it 'queues a delivery job' do
      expect {
        federated_message
      }.to enqueue_job(ActivityPub::DeliveryJob)
    end

    it 'sends to the actual inbox successfully', vcr: { record: :new_episodes } do
      perform_enqueued_jobs do
        federated_follow
        expect(ActivityPub::Request).to receive(:new).with("http://localhost:3000/inbox", {
          from_account: eql(local_federated_account),
          verb: :post,
          body: kind_of(String)
        }).and_call_original
        expect_any_instance_of(ActivityPub::Request).to receive(:perform).and_call_original
        federated_message
      end
    end
  end
end
