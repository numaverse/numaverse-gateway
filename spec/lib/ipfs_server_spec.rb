require 'rails_helper'

describe IpfsServer do
  let(:ipfs_hash) { 'QmXExS4BMc1YrH6iWERyryFcDWkvobxryXSwECLrcd7123' }
  let(:decoded_hash) { '8443bcbb6a0118aebfcfe91c125d6e58a87693b73d08f77d77f6e78fa227bf0c' }
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

  describe 'hash_data' do
    it 'raises if an invalid hash is passed' do
      expect { IpfsServer.hash_data('Qmasdfsd && echo "hello"') }.to raise_error(StandardError)
    end

    it 'works for valid input' do
      expect(IpfsServer.hash_data(ipfs_hash)).to eql([18,32, decoded_hash])
    end
  end

  describe 'data_to_hash' do
    it 'raises if invalid input' do
      expect { IpfsServer.data_to_hash(18, 32, ' asdf && echo "hello"') }.to raise_error(StandardError)
    end

    it 'works for valid input' do
      expect(IpfsServer.data_to_hash(18, 32, decoded_hash)).to eql(ipfs_hash)
    end
  end
end