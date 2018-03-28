require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'address' do
    it 'removes 0x' do
      account = build(:account, address: '0x0')
      account.save
      expect(account.address).to eql('0')
    end

    it 'validates that address with 0x isnt valid' do
      account = build(:account, address: '0x'+SecureRandom.hex(32))
      account.has_no_0x
      expect(account.errors[:address]).not_to be_blank
    end
  end

  describe '.make_by_address' do
    it 'creates a new account' do
      hex = '0x'+SecureRandom.hex(32)
      account = Account.make_by_address(hex)
      expect(account).to be_valid
      expect(account.hash_address).to eql(hex)
    end

    it 'finds existing accounts' do
      account = create(:account)
      found = Account.make_by_address(account.address)
      expect(found).to eql(account)
    end
  end

  it 'updates balance from the network' do
    expect_any_instance_of(Ethereum::Client).to receive(:eth_get_balance).and_return({'result' => 1000.to_hex})
    account = create(:account)
    account.update_balance
    expect(account.balance_nuwei).to eql(1000)
  end

  describe 'ipfs_json' do
    let(:account) { create(:account_with_data) }

    it 'sets data for activitypub' do
      ipfs_json = account.ipfs_json
      expect(ipfs_json).to eql(ActivityPub::Person.new(account).data)
    end
  end

  describe '#federated_account' do
    let(:account) { create(:account_with_data) }

    it 'creates a federated account when transacted' do
      expect(account.federated_account).to be_blank
      account.transact
      fed_account = account.reload.federated_account
      expect(fed_account).to be_present
      expect(fed_account.username).to eql(account.username)
      expect(fed_account.display_name).to eql(account.display_name)
      username = Faker::Internet.user_name.gsub(".","_")
      display_name = Faker::Name.name
      account.update(username: username, display_name: display_name)
      account.transact
      fed_account.reload
      expect(fed_account.username).to eql(username)
      expect(fed_account.display_name).to eql(display_name)
    end
  end

end
