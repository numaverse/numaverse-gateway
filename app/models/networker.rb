class Networker
  class << self

    def get_client
      if ENV['RPC_ADDRESS'].present?
        Ethereum::Client.create(ENV['RPC_ADDRESS'])
      else
        Ethereum::HttpClient.new("http://localhost:8545")
      end
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