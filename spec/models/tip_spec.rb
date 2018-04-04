require 'rails_helper'

RSpec.describe Tip, type: :model do
  describe 'send_notifications' do
    it 'makes a tip' do
      from = account_with_balance
      to = create(:account, email: 'hank@numaverse.com')
      original = create(:message, account: to)
      tx = transfer_eth(from, original.account, 100)

      from_message = create(:message, account: from)
      tip = from.from_tips.build(
        to_account: original.account,
        tx_id: tx.id,
        tx_hash: tx.hash_address,
        to_message: original,
        message: from_message,
      )

      expect(tip).to receive(:send_notifications).and_call_original
      delivery = double
      expect(delivery).to receive(:deliver_later).with(no_args)
      expect(NotificationMailer).to receive(:tip).with(instance_of(Tip)).and_return(delivery)

      tip.save
    end
  end
end
