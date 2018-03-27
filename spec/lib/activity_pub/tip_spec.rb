require 'rails_helper'

describe ActivityPub::Tip do
  let(:from) { account_with_balance }
  let(:to) { create(:account) }
  let(:tip) { from.tip(to, 500) }
  let(:stream) { tip.activity_stream }
  let(:data) { stream.hashie_data }

  skip 'creates a tip object' do
    # ap data
    expect(data.type).to eql("Tip")
    expect(data.valueNuwei).to eql(500)

    to = ActivityPub::Person.new(tip.to_account).object_data
    expect(stream.data[:object]).to eql(to)

    from = ActivityPub::Person.new(tip.from_account).object_data
    expect(stream.data[:actor]).to eql(from)

    expect(data.transactionHash).to eql(tip.tx.hash_address)
  end

  context 'with a message' do
    let(:message) { create(:message) }
    let(:tip) { from.tip(to, 500, message) }
    skip 'works with a message' do
      expect(tip.to_message).to eql(message)

      message_data = ActivityPub::Message.new(message).object_data
      expect(stream.data[:toMessage]).to eql(message_data)
    end
  end
  
end