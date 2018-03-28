require 'rails_helper'

RSpec.describe ActivityPubController, type: :controller do
  render_views
  let(:account)  { create(:account_with_data) }
  let(:json) { Hashie::Mash.new(JSON.parse(response.body)) }

  describe '#outbox' do
    before do
      @m1 = message_with_history(account)
      @m2 = message_with_history(account)
      get :outbox, params: { account_id: account.hash_address }
    end

    it 'returns application/activity+json' do
      expect(response.content_type).to eq 'application/activity+json'
    end

    it 'sets basic outbox properties' do
      expect(json['@context'][1]).to hash_eql(ActivityPub::ActivityStream.new(nil).context[1])
      expect(json['@context'].first).to eql(ActivityPub::ActivityStream.new(nil).context.first)
      expect(json.id).to eql(ap_outbox_url(account_id: account.hash_address))
      expect(json.totalItems).to eql(4)
      expect(json.type).to eql('OrderedCollection')
    end

    it 'sets proper orderedItems' do
      versions = account.federated_message_versions.most_recent
      versions.each_with_index do |version, index|
        item = json.orderedItems[index]
        expect(item.object.except('url', 'id','to')).to hash_eql(version.object_changes.except('actor', 'id'))
        expect(item.to).to include("https://www.w3.org/ns/activitystreams#Public")
        expect(item.id).to eql(ap_activity_url(version.id))
        expect(item.object.url).to eql(message_url(version.federated_message.local_message_id))
        expect(item.object.id).to eql(ap_message_url(version.federated_message_id))
        expect(item.published).to eql(version.created_at.strftime('%Y-%m-%dT%H:%M:%S.%LZ'))
        if version.created?
          expect(item.type).to eql('Create')
        elsif version.updated?
          expect(item.type).to eql('Update')
        elsif version.deleted?
          expect(item.type).to eql('Delete')
        end
      end
    end

    it 'sets actor property for items' do
      json.orderedItems.each do |item|
        expect(item.actor).to eql(ap_account_url(account_id: account.hash_address))
      end
    end
  end

  describe '#webfinger' do
    before do
      get :webfinger, params: { resource: "acct:#{account.username}@test.host"}
    end

    it 'fetches a user from webfinger format' do
      expect(json.subject).to eql("acct:#{account.username}@test.host")
      aliases = json.aliases
      expect(aliases.size).to eql(1)
      expect(aliases.first).to eql(account_url(id: account.hash_address))
      links = json.links
      expect(links.size).to eql(1)
      apub_link = links.find { |l| l.rel == 'self' }
      expect(apub_link).to be_present
      expect(apub_link.type).to eql('application/activity+json')
      expect(apub_link.href).to eql(ap_account_url(account.hash_address))
    end
  end

  describe '#account' do
    let(:account) { create(:transacted_account) }
    let(:federated_account) { account.reload.federated_account }
    before do
      get :account, params: { account_id: account.hash_address }
    end

    it 'sets account data' do
      # ap icon
      expect(json['@context'][1]).to hash_eql(ActivityPub::ActivityStream.new(nil).context[1])
      expect(json['@context'].first).to eql(ActivityPub::ActivityStream.new(nil).context.first)
      expect(json.id).to eql(ap_account_url(account.hash_address))
      expect(json.name).to eql(account.display_name)
      expect(json.preferredUsername).to eql(account.username)
      expect(json.type).to eql("Person")
      expect(json.icon).to hash_eql(account.activity_stream.data[:icon])
      expect(json.outbox).to eql(ap_outbox_url(account.hash_address))
      expect(json.inbox).to eql(ap_inbox_url(account.hash_address))
      expect(json.followers).to eql(ap_followers_url(account.hash_address))
      pubkey = json.publicKey
      expect(pubkey.id).to eql(ap_account_url(account.hash_address, anchor: 'main-key'))
      expect(pubkey.owner).to eql(ap_account_url(account.hash_address))
      expect(pubkey.publicKeyPem).not_to be_blank
      expect(pubkey.publicKeyPem).to eql(federated_account.public_key)
    end
    
  end

  describe '#message' do
    pending 'sets message data'
  end

  describe '#activity' do
    before do
      @message = message_with_history(account)
      @version = @message.federated_message.versions.last
      get :activity, params: { version_id: @version.id }
    end

    it 'sets version data' do
      expect(json.object.to).to eql(['https://www.w3.org/ns/activitystreams#Public'])
      expect(json.object.content).to eql(@version.object_changes['content'])
      expect(json.type).to eql('Update')
    end
  end

  describe '#inbox_incoming_message', :vcr do
    let(:account) { create(:transacted_account, address: '0x8d3e4e4b76e60b5371e23103539f24ae5d43b359') }
    let(:federated_account) { account.reload.federated_account }

    def make_follow_request(type)
      body = file_fixture("inbox_#{type}_follow.json").read.gsub("\n", ' ')
      headers = JSON.parse(file_fixture("inbox_#{type}_follow_headers.json").read)
      @request.headers.merge!(headers.slice('Date', 'Signature', 'Digest', 'Host'))
      @request.headers['Content-Type'] = 'application/activity+json'
      @request.headers['User-Agent'] = headers['Agent']
      post :inbox_incoming_message, params: { account_id: account.hash_address }, body: body
    end

    it 'validates signatures' do
      make_follow_request('create')
      expect(response).to be_success
    end

    it 'creates a federated follow' do
      perform_enqueued_jobs do
        make_follow_request('create')
      end
      follow = federated_account.to_follows.first
      expect(follow).to be_present
      expect(follow.to_account).to eql(federated_account)
      expect(follow.from_account.federated_id).to eql('http://localhost:3000/users/admin')
      expect(follow.federated_id).to eql('http://localhost:3000/users/admin#follows/22')
    end

    it 'works with an Undo follow later' do
      perform_enqueued_jobs do
        make_follow_request('create')
      end
      follow = federated_account.to_follows.first
      expect(follow).to be_present
      perform_enqueued_jobs do
        make_follow_request('undo')
      end
      expect { follow.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'followers', :vcr do
    let(:account) { create(:transacted_account) }
    let(:federated_account) { account.reload.federated_account }
    let(:from_local_account) { create(:transacted_account) }
    let(:from_account) { from_local_account.update_federated_model }
    let!(:federated_follow) { create(:federated_follow, from_account: from_account, to_account: federated_account) }
    let!(:remote_follow) { create(:federated_follow, from_account: Federated::Account.from_remote_id("http://localhost:3000/users/admin"), to_account: federated_account) }
    before do
      get :followers, params: { account_id: account.hash_address }
    end
    
    it 'shows followers' do
      expect(json.id).to eql(ap_followers_url(account.hash_address))
      expect(json.totalItems).to eql(2)
      expect(json.orderedItems.first).to eql(ap_account_url(from_local_account.hash_address))
      expect(json.orderedItems[1]).to eql("http://localhost:3000/users/admin")
    end
  end

  describe 'following', :vcr do
    let(:account) { create(:transacted_account) }
    let(:federated_account) { account.reload.federated_account }
    let(:to_local_account) { create(:transacted_account) }
    let(:to_account) { to_local_account.update_federated_model }
    let(:to_remote_account) { create(:remote_account) }
    let!(:federated_follow) { create(:federated_follow, from_account: federated_account, to_account: to_account) }
    let!(:remote_follow) { create(:federated_follow, from_account: federated_account, to_account: to_remote_account) }
    before do
      get :following, params: { account_id: account.hash_address }
    end
    
    it 'shows following' do
      expect(json.id).to eql(ap_following_url(account.hash_address))
      expect(json.totalItems).to eql(2)
      expect(json.orderedItems.first).to eql(ap_account_url(to_local_account.hash_address))
      expect(json.orderedItems[1]).to eql("http://localhost:3000/users/admin")
    end
  end
end
