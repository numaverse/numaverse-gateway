require 'rails_helper'

RSpec.describe Federated::Follow, type: :model do
  describe '#deliver!' do
    it 'enqueues a delivery job' do
      expect {
        create(:federated_follow)
      }.to enqueue_job(ActivityPub::DeliveryJob)
    end

    it 'delivers the follow request', :vcr do
      perform_enqueued_jobs do
        account = real_federated_account
        to_account = create(:remote_account, inbox_url: 'http://localhost:3000/inbox')
        expect(ActivityPub::Request).to receive(:new).with("http://localhost:3000/inbox", {
          from_account: eql(account),
          verb: :post,
          body: kind_of(String)
        }).and_call_original
        expect_any_instance_of(ActivityPub::Request).to receive(:perform).and_call_original
        create(:federated_follow, from_account: account, to_account: to_account)
      end
    end
  end
end
