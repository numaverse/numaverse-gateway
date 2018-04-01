require 'rails_helper'

describe ActivityPub::Follow do
  let(:follow) { create(:follow) }
  let(:stream) { ActivityPub::Follow.new(follow) }
  let(:data) { stream.hashie_data }
  let(:urls) { Rails.application.routes.url_helpers }

  it 'sets some data' do
    expect(data.type).to eql("Follow")
    from = ActivityPub::Person.new(follow.from_account).object_data
    expect(stream.data[:actor]).to eql(from)

    to = ActivityPub::Person.new(follow.to_account).object_data
    expect(stream.data[:object]).to eql(to)
    expect(data.id).to eql(urls.follow_url(follow))
  end

  it 'sets hiddenAt' do
    follow = create(:follow, hidden_at: DateTime.now)
    expect(follow.activity_stream.hashie_data.hiddenAt).not_to be_nil
  end

  context 'federated follows' do
    let(:follow) { create(:federated_follow) }

    it 'sets URI for target and object' do
      expect(data.object).to eql(follow.to_account.url_id)
      expect(data.actor).to eql(follow.from_account.url_id)
    end
  end
end