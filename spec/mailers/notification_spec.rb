require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "mention" do
    let(:account) { create(:account_with_data) }
    let(:message) { create(:message) }
    let(:mail) { NotificationMailer.mention(account, message) }

    it "renders the headers" do
      expect(mail.subject).to eq("You've been mentioned in a message on Numa")
      expect(mail.to).to eq([account.email])
      expect(mail.from).to eq(["hello@numachain.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(message.body)
    end
  end

  describe 'tip', :vcr do
    it 'sends a tip' do
      from = account_with_balance
      to = create(:account_with_data)
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

      mail = NotificationMailer.tip(tip)

      expect(mail.to).to eql([to.email])
      expect(mail.body.encoded).to match(from_message.body)
    end
  end

  describe 'favorite' do
    it 'sends a notification' do
      favorite = create(:favorite, account: create(:account_with_data))
      mail = NotificationMailer.favorite(favorite)
      
      expect(mail.to).to eql([favorite.message.account.email])
      expect(mail.body.encoded).to match(favorite.message.body)
    end
  end

  describe '#reply' do
    let(:notified) { create(:account_with_data) }
    let(:original) { create(:message, account: notified) }
    let(:reply) { create(:message, reply_to: original) }

    it 'sends a notification' do
      mail = NotificationMailer.reply(reply)
      expect(mail.to).to eql([notified.email])
      expect(mail.body.encoded).to match(reply.body)
      expect(mail.body.encoded).to match(original.body)
    end
  end

  describe '#repost' do
    let(:notified) { create(:account_with_data) }
    let(:original) { create(:message, account: notified) }
    let(:repost) { create(:message, repost: original) }

    it 'sends a notification' do
      mail = NotificationMailer.repost(repost)
      expect(mail.to).to eql([notified.email])
      expect(mail.body.encoded).to match(original.body)
    end
  end

end
