class IpfsServer
  class << self
    def client
      IPFS::Client.new(
        host: ipfs_address, 
        port: ipfs_port,
        user: ENV['IPFS_USER'],
        password: ENV['IPFS_PASSWORD']
      )
    end

    def ipfs_address
      ENV['IPFS_ADDRESS'] || 'http://localhost'
    end

    def ipfs_port
      (ENV['IPFS_PORT'] || 5001).to_i
    end

    def add(file)
      client.add(file)
    end

    def uri
      uri = Addressable::URI.parse(ENV['IPFS_ADDRESS'])
      port = ipfs_port
      uri.port = port unless [80, 443].include?(port)
      uri
    end

    def image_address
      ENV['IPFS_IMAGE_ADDRESS'] || 'https://ipfs.numaverse.com'
    end

    def image_url(hash, size: nil)
      url = "#{image_address}/image/#{hash}"
      url += "?size=#{size}" if size
      url
    end

    def gateway_address
      url = uri
      url.port = 8080 if url.port == 5001
      url
    end

    def gateway_url(hash)
      url = gateway_address
      url.path = "/ipfs/#{hash}"
      url.to_s
    end

    def cat(hash)
      Timeout.timeout(10) {
        Hashie::Mash.new JSON.parse(client.cat(hash))
      }
    end

    def hash_data(hash)
      unless /^[a-zA-Z0-9]{46}$/.match?(hash)
        raise 'Tried to decode an invalid IPFS hash'
      end

      args = [
        'decode',
        hash
      ]
      hash_function, hash_size, hex = `node app/javascript/ipfs.js #{args.join(' ')}`.split("\n")
      return hash_function.from_hex, hash_size.from_hex, hex
    end

    def data_to_hash(hash_function, hash_size, hex)
      unless /^[a-zA-Z0-9]{64}$/.match(hex)
        raise 'Tried to encode invalid IPFS hex'
      end

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