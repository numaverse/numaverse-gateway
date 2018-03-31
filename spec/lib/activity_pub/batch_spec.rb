require 'rails_helper'

describe ActivityPub::Batch do
  let(:account) { create(:account) }
  let(:follow) { create(:follow, from_account: account) }
  let(:message) { create(:message, account: account) }
  let(:article) { create(:article, account: account) }
  let(:batch) { account.fetch_batch }
  let(:data) { batch.activity_stream.hashie_data }

  before do
    account.batch
    follow.batch
    message.batch
    article.batch
  end

  it 'makes a batch correctly' do
    expect(data.totalSize).to eql(4)
    expect(data.uuid).to eql(batch.uuid)
    items = data.orderedItems
    expect(items.size).to eql(4)
    expect(items[0]).to hash_eql(account.activity_stream.object_data)
    expect(items[1]).to hash_eql(follow.activity_stream.object_data)
    expect(items[2]).to hash_eql(message.activity_stream.object_data)
    expect(items[3]).to hash_eql(article.activity_stream.object_data)
  end
end

