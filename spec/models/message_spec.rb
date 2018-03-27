require 'rails_helper'

RSpec.describe Message, type: :model do

  describe 'send_mentions' do
    skip 'sends mentions to users' do
      mention = create(:user)
      expect {
        message = create(:message, body: "Hello @#{mention.username}")
      }.to enqueue_job(ActionMailer::DeliveryJob)
    end
  end

  describe 'linkify_body' do
    it 'adds links to raw text' do
      message = build(:message, json_schema: :micro, body: 'hey @vitalik, $eth is the greatest invention of this century')
      expect(message.linkify_body).to eql(WebText.format(message.body))
      formatted = message.linkify_body
      expect(formatted).to include("<a href='/u/vitalik' class='web-text__username'>@vitalik</a>")
      expect(formatted).to include("<a href='/all?query=$eth' class='web-text__hashtag'>$eth</a>")
    end
  end

  describe 'micro' do
    it 'cant have a body longer than 280' do
      message = build(:message, body: SecureRandom.hex(150))
      expect(message).not_to be_valid
      expect(message.errors['body']).not_to be_blank
    end
  end

  describe 'article' do
    it 'can have body longer than 280' do
      message = build(:message, body: SecureRandom.hex(150), json_schema: :article)
      expect(message).to be_valid
    end
  end

  describe 'federated_message' do
    it 'creates a federated message when confirmed' do
      message = create(:message)
      expect(message.federated_message).to be_blank
      message.confirm
      fed_message = message.reload.federated_message
      expect(fed_message).to be_present
      expect(fed_message.object_data).to hash_eql(message.activity_stream.object_data)
      expect(fed_message.local_account_id).to eql(message.account_id)

      message.update(aasm_state: 'uploaded', body: 'another')
      message.confirm

      fed_message = message.reload.federated_message
      expect(fed_message.object_data).to hash_eql(message.activity_stream.object_data)
    end    
  end
end
