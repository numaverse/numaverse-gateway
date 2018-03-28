require 'rails_helper'

describe IpfsServer do
  let(:ipfs_hash) { 'QmXExS4BMc1YrH6iWERyryFcDWkvobxryXSwECLrcd7123' }
  describe '.image_url' do
    it 'uses a custom address' do
      old_address = ENV['IPFS_IMAGE_ADDRESS']
      ENV['IPFS_IMAGE_ADDRESS'] = 'https://myipfsserver.com'

      expect(IpfsServer.image_url(ipfs_hash)).to eql("https://myipfsserver.com/image/#{ipfs_hash}")

      ENV['IPFS_IMAGE_ADDRESS'] = old_address
    end

    it 'uses ipfs.numaverse.com as default' do
      expect(IpfsServer.image_url(ipfs_hash)).to eql("https://ipfs.numaverse.com/image/#{ipfs_hash}")
    end
  end

  describe '.gateway_url' do
    it 'uses a custom address' do
      old_address = ENV['IPFS_ADDRESS']
      old_port = ENV['IPFS_PORT']

      ENV['IPFS_ADDRESS'] = 'https://myipfs.com'
      ENV['IPFS_PORT'] = '443'

      expect(IpfsServer.gateway_url(ipfs_hash)).to eql("https://myipfs.com/ipfs/#{ipfs_hash}")

      ENV['IPFS_ADDRESS'] = old_address
      ENV['IPFS_PORT'] = old_port
    end

    it 'uses localhost as default' do
      expect(IpfsServer.gateway_url(ipfs_hash)).to eql("http://localhost:8080/ipfs/#{ipfs_hash}")
    end
  end
end