module ActivityPubSpecHelpers
  def message_with_history(account)
    message = create(:message, account: account)
    message.confirm
    message.reload
    message.update(body: Faker::Lorem.sentence)
    message.confirm
    message.reload
  end
end