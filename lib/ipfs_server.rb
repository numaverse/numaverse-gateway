class IpfsServer
  class << self
    def client
      IPFS::Client.new(
        host: ENV['IPFS_ADDRESS'] || 'http://localhost', 
        port: ENV['IPFS_PORT'] || 5001,
        user: ENV['IPFS_USER'],
        password: ENV['IPFS_PASSWORD']
      )
    end

    def add(file)
      client.add(file)
    end

    def cat(hash)
      Timeout.timeout(10) {
        Hashie::Mash.new JSON.parse(client.cat(hash))
      }
    end

    def hash_data(hash)
      args = [
        'decode',
        hash
      ]
      hash_function, hash_size, hex = `node app/javascript/ipfs.js #{args.join(' ')}`.split("\n")
      return hash_function.from_hex, hash_size.from_hex, hex
    end

    def data_to_hash(hash_function, hash_size, hex)
      args = [
        'encode',
        hash_function.to_s(16),
        hash_size.to_s(16),
        hex
      ]

      hash = `node app/javascript/ipfs.js #{args.join(' ')}`.split("\n").first
    end
  end
end