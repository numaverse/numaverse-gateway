module NumaChain
  class Deploy
    class << self
      def deploy!
        tries ||= 5
        client = Networker.get_client
        contract = Ethereum::Contract.create(file: "#{Rails.root}/contracts/Messages.sol", client: client)
        Contract.update_address :messages, contract.deploy_and_wait
        contract = Ethereum::Contract.create(file: "#{Rails.root}/contracts/Users.sol", client: client)
        contract = Contract.update_address :users, contract.deploy_and_wait
      rescue => e
        retry unless (tries -= 1).zero?
        raise e
      end
    end
  end
end