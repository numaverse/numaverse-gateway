require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  skip "mention" do
    let(:user) { create(:user) }
    let(:message) { create(:message) }
    let(:mail) { NotificationMailer.mention(user, message) }

    it "renders the headers" do
      expect(mail.subject).to eq("You've been mentioned in a message on Numa")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["hello@numachain.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(message.body)
    end
  end

end
