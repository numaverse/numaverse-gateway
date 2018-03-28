require 'rails_helper'

describe ActivityPub::Person do
  let(:account) { create(:account_with_data, ipfs_hash: 'Qm' + SecureRandom.hex(22)) }
  let(:person) { ActivityPub::Person.new(account) }
  let(:data) { person.hashie_data }
  let(:urls) { Rails.application.routes.url_helpers }

  it 'sets the context' do
    context = data['@context']
    expect(context).to include("https://www.w3.org/ns/activitystreams")
    custom = context.last
    expect(custom.numa).to eql("https://numaverse.com/ns")
    expect(custom.address).to eql("numa:address")
    expect(custom.location).to eql("numa:location")
  end

  it 'sets some basic info' do
    expect(data.id).to eql(urls.account_url(account.username))
    expect(data.url).to eql(urls.account_url(account.username))
    expect(data.preferredUsername).to eql(account.username)
    expect(data.name).to eql(account.display_name)
    expect(data.summary).to eql(account.bio)
    expect(data.address).to eql(account.hash_address)
    expect(data.type).to eql("Person")
    expect(data.ipfs_hash).to eql(account.ipfs_hash)
  end

  it 'sets the icon' do
    icon = data.icon
    expect(icon.type).to eql("Image")
    expect(icon.url).to eql("https://ipfs.numaverse.com/image/#{account.avatar_ipfs_hash}")
  end
end