module NumaChain
  class Deploy
    class << self
      def deploy!
        tries ||= 5
        client = Networker.get_client
        contract = Ethereum::Contract.create(file: "#{Rails.root}/contracts/Numa.sol", client: client)
        contract_address = contract.deploy_and_wait
        creation_tx = Transaction.make_by_address(contract.deployment.id)
        contract = Contract.update_address :numa, contract_address, creation_tx
        creation_tx.update(to_account: Account.make_by_address(contract.hash_address))
      rescue => e
        retry unless (tries -= 1).zero?
        raise e
      end
    end
  end
end