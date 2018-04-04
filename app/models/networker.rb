class Networker
  ETH_USD_CACHE_KEY = 'eth_usd_cache_key'

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
        output, status = Open3.capture2('node',"#{Rails.root}/app/javascript/commands/validate-signature.js", signature)
        if status.exitstatus == 0
          output.split("\n").first
        else
          raise ArgumentError.new("Error when validating signature: #{signature}. Message: #{output}")
        end
      else
        raise ArgumentError.new("Tried to validate an invalid signature: #{signature}")
      end
    end

    def eth_usd
      Rails.cache.fetch(ETH_USD_CACHE_KEY, expires_in: 10.minutes) do
        url = 'https://api.coinmarketcap.com/v1/ticker/ethereum/'
        response = HTTParty.get(url)
        price = JSON.parse(response.body)[0]['price_usd'].to_f
        (price * 100.0).round / 100.0
      end.to_f
    end
  end
end