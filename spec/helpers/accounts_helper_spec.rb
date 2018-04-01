require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the AccountsHelper. For example:
#
# describe AccountsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe AccountsHelper, type: :helper do
  describe '#link_to_account' do
    it 'returns nil if blank' do
      expect(helper.link_to_account(nil)).to be_nil
    end

    it 'returns Numa if matches the contract' do
      tx = Transaction.create(address: '0x1234')
      Contract.update_address :numa, '0x1234', tx
      account = Account.make_by_address(Contract.numa.address)
      expect(helper.link_to_account(account)).to eql('Numa Smart Contract')
    end

    it 'returns short hash address if no username' do
      account = create(:account)
      expect(helper.link_to_account(account)).to eql(helper.short_address(account.hash_address, length: 15))
    end

    it 'returns link with username if present' do
      account = create(:account_with_data)
      link = helper.link_to_account(account)
      expect(link).to eql(link_to("@#{account.username}", account_path(account.username)))
    end
  end

  describe '#short_address' do
    it 'shortens the address' do
      address = '0x6074bb9ec184196f5de132a1410aac6b241fb31b'
      expect(helper.short_address(address)).to eql('0x6074..fb31b')
    end
  end

  describe '#default_avatar' do
    it 'returns avatar with size' do
      expect(helper.default_avatar(size: :large)).to eql("/avatar/Avatar@large.png")
    end
  end

  describe '#ipfs_image_url' do
    it 'returns a link to image proxy server' do
      hash = SecureRandom.hex(10)
      expect(helper.ipfs_image_url(hash, size: :large)).to eql(IpfsServer.image_url(hash, size: 800))
    end
  end

  describe '#account_avatar' do
    it 'returns ipfs image if present' do
      account = create(:account, avatar_ipfs_hash: SecureRandom.hex(10))
      expect(helper.account_avatar(account)).to eql(IpfsServer.image_url(account.avatar_ipfs_hash, size: 400))
    end

    it 'returns default avatar if not available' do
      account = create(:account)
      expect(helper.account_avatar(account)).to eql('/avatar/Avatar@medium.png')
    end
  end
end
