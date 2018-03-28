module NumaChain
  class Deploy
    class << self
      def deploy!
        tries ||= 5
        client = Networker.get_client
        contract = Ethereum::Contract.create(file: "#{Rails.root}/contracts/Numa.sol", client: client)
        contract = Contract.update_address :numa, contract.deploy_and_wait
      rescue => e
        retry unless (tries -= 1).zero?
        raise e
      end
    end
  end
end