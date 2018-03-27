require 'rails_helper'

describe ActivityPub::Favorite do
  let(:favorite) { create(:favorite) }
  let(:stream) { ActivityPub::Favorite.new(favorite) }
  let(:data) { stream.hashie_data }
  let(:urls) { Rails.application.routes.url_helpers }

  it 'sets some data' do
    expect(data.type).to eql("Like")
    message = ActivityPub::Message.new(favorite.message).object_data
    expect(stream.data[:object]).to eql(message)
    person = ActivityPub::Person.new(favorite.account).object_data
    expect(stream.data[:actor]).to eql(person)
  end

  it 'sets hiddenAt' do
    favorite = create(:favorite, hidden_at: DateTime.now)
    expect(favorite.activity_stream.hashie_data.hiddenAt).not_to be_nil
  end
end