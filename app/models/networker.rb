class Networker
  class << self

    def get_client
      if ENV['RPC_ADDRESS'].present?
        Ethereum::Client.create(ENV['RPC_ADDRESS'])
      else
        Ethereum::HttpClient.new("http://localhost:8545")
      end
    end

    def get_contract(name, address: )
      @contract ||= begin
        file = File.read("#{Rails.root}/build/contracts/#{name}.json")
        json = JSON.parse(file)
        abi = json['abi']
        bytecode = json['bytecode']
        client = get_client
        contract = Ethereum::Contract.create(client: get_client, abi: abi, code: bytecode, name: name)
        contract
      end
    end

    def get_message(id, contract)
      sender, hex = contract.call.messages(id)
      hex = hex.unpack('H*').first
      ipfs_hash = IpfsServer.data_to_hash(18, 32, hex)
      Hashie::Mash.new(
        foreign_id: id,
        sender: sender,
        
        ipfs_hash: ipfs_hash
      )
    end

    def events(contract, name)
      eth_contract = contract.eth_contract
      event_abi = eth_contract.abi.find {|a| a['name'] == name}
      event_inputs = event_abi['inputs'].map {|i| OpenStruct.new(i)}
      decoder = Ethereum::Decoder.new

      filter = { to_block: 'latest' }

      latest_event = contract.contract_events.where(event_name: name).order('created_at desc').first
      if last_block = latest_event.try(:tx).try(:block).try(:number)
        filter[:from_block] = (last_block + 1).to_hex
      end

      filter_id = eth_contract.new_filter.send(name.underscore, filter)

      events = eth_contract.get_filter_logs.send(name.underscore, filter_id)
      events.map do |event|
        Hashie::Mash.new(event)
      end
    end

    def message_created_events
      messages_events(name: 'MessageCreated')
    end

    def message_updated_events
      messages_events(name: 'MessageUpdated')
    end

    def messages_events(name:)
      contract = Contract.numa
      events = events(contract, name)
    end

    def users_events
      contract = Contract.numa
      events = events(contract, 'UserUpdated')
    end

    def validate_signature(signature)
      if /^0x[a-zA-Z\d]{130}$/.match?(signature)
        output = `node app/javascript/commands/validate-signature.js #{signature}`
        if $?.exitstatus == 0
          output.split("\n").first
        else
          raise ArgumentError.new("Error when validating signature: #{signature}. Message: #{output}")
        end
      else
        raise ArgumentError.new("Tried to validate an invalid signature: #{signature}")
      end
    end
  end
end