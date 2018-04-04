require 'rails_helper'

describe Networker do
  let(:pool) { user_pool_account }

  describe '.get_client' do
    before(:each) do
      @old_rpc = ENV['RPC_ADDRESS']
    end
    after(:each) do
      if @old_rpc
        ENV['RPC_ADDRESS'] = @old_rpc
      else
        ENV.delete('RPC_ADDRESS')
      end
    end

    it 'returns localhost:8500 by default' do
      ENV.delete('RPC_ADDRESS')
      client = Networker.get_client
      expect(client).to be_a(Ethereum::HttpClient)
      expect(client.host).to eql('localhost')
      expect(client.port).to eql(8545)
    end

    it 'returns ENV["RPC_ADDRESS"] if present' do
      ENV['RPC_ADDRESS'] = 'http://mynode.com:8080'
      client = Networker.get_client
      expect(client).to be_a(Ethereum::HttpClient)
      expect(client.host).to eql('mynode.com')
      expect(client.port).to eql(8080)
      expect(client.ssl).to be false
    end

    it 'returns ENV["RPC_ADDRESS"] is https' do
      ENV['RPC_ADDRESS'] = 'https://mynode.com'
      client = Networker.get_client
      expect(client).to be_a(Ethereum::HttpClient)
      expect(client.host).to eql('mynode.com')
      expect(client.port).to eql(443)
      expect(client.ssl).to be true
    end

    it 'works if specified address is IPC' do
      ENV['RPC_ADDRESS'] = '/Users/tester/ethereum.ipc'
      client = Networker.get_client
      expect(client).to be_a(Ethereum::IpcClient)
      expect(client.ipcpath).to eql('/Users/tester/ethereum.ipc')
    end

    it 'sets username and password if specified' do
      ENV['RPC_ADDRESS'] = 'https://username:password@mynode.com'
      client = Networker.get_client
      expect(client).to be_a(Ethereum::HttpClient)
      expect(client.user).to eql('username')
      expect(client.password).to eql('password')
      expect(client.ssl).to be true
    end
  end

  describe '.validate_signature' do
    it 'finds the address of a valid signature' do
      sig = '0x641a251cce30223cbcf391ecfe3aa939acc7361bbaf166dd929f940bf6589f8b3a2defc1b19c5db7f5816cc83a07a1be5a452e0387491a52e3b50c5138b7acb81c'
      expect(Networker.validate_signature(sig)).to eql("0x061ab91505a9e3d993cc27e7bc22a77b26a456bd")
    end

    it 'rejects invalid input' do
      sig = "0x641a251cce30223cbcf391ecfe3aa939acc7361bbaf166dd929f940bf6589f8b3a2defc1b19c5db7f5816cc83a07a1be5a452e0387491a52e3b50c5138b7acb81c && echo hello"
      expect { Networker.validate_signature(sig) }.to raise_error(ArgumentError)
      expect { Networker.validate_signature("; echo 'hi'") }.to raise_error(ArgumentError)
    end

    it 'rejects invalid signatures' do
      sig = "0x123a251cce30223cbcf391ecfe3aa939acc7361bbaf166dd929f940bf6589f8b3a2defc1b19c5db7f5816cc83a07a1be5a452e0387491a52e3b50c5138b7acb81c"
      expect(Networker.validate_signature(sig)).not_to eql("0x061ab91505a9e3d993cc27e7bc22a77b26a456bd")
    end
  end

  describe 'eth_usd' do
    it 'fetches the ticker from coinmarketcap', :vcr do
      price = Networker.eth_usd
      expect(price).to eql(415.16)
    end
  end
end