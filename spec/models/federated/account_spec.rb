require 'rails_helper'

RSpec.describe Federated::Account, type: :model do
  let(:account) { create(:transacted_account) }
  let(:federated_account) { account.reload.federated_account }

  describe '#keys' do
    it 'sets a public / private key pair' do
      expect(federated_account.private_key).not_to be_blank
      expect(federated_account.public_key).not_to be_blank
    end
  end

  describe '.from_remote_id', :vcr do
    it 'fetches a remote user' do
      id = 'https://mastodon.social/users/hstove'
      account = Federated::Account.from_remote_id(id)
      expect(account.federated_id).to eql(id)
      expect(account.username).to eql('hstove')
      expect(account.display_name).to eql('Hank')
      expect(account.public_key).to eql("-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtxRTVA7Su8N2H+C10irt\nh8bP5aXd4HAyM1c4LIHh2M/fd10j2578Kups4+V4ufwwF18ICzGrljZgyvh4jxtc\ntRmtI8hVWpA1YI648Zl5ldvKoW/sNPbWG4rnOlWNrjWaBeTX6Xh5et0319GhyLRk\nRA8UB04E1PljSRz+9QA5V03LYQi5YDFSemPIBhXsgiz4xfYFRoT37zRqp6bmAfsk\nfjW+60HF6eNSDGRhBoVyJwhYhyr+VPbhu0j7FXWAwQBgcquZZvq8zf2ehzDjFf0y\nZeHUjC0rQH68Bb5mO0gd8T8Wtfy8taovIdPAOSsG57TpLhjwAPePy8JNgZykw3M7\n2wIDAQAB\n-----END PUBLIC KEY-----\n")
      expect(account.avatar_url).to eql('https://files.mastodon.social/accounts/avatars/000/292/391/original/b7345e5d5ef91433.jpg')
      expect(account.shared_inbox_url).to eql('https://mastodon.social/inbox')
      expect(account.inbox_url).to eql('https://mastodon.social/users/hstove/inbox')
      expect(account.outbox_url).to eql('https://mastodon.social/users/hstove/outbox')
      expect(account.followers_url).to eql('https://mastodon.social/users/hstove/followers')
      expect(account.following_url).to eql('https://mastodon.social/users/hstove/following')
      data = Hashie::Mash.new(account.object_data)
      expect(data.inbox).to eql('https://mastodon.social/users/hstove/inbox')
      expect(data.outbox).to eql('https://mastodon.social/users/hstove/outbox')
      expect(data['@context']).to be_nil
    end
  end
end
