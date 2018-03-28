class Contract < ApplicationRecord
  include HashAddressable
  has_many :contract_events

  validates_presence_of :name
  validates_uniqueness_of :name

  enum name: {
    numa: 2,
  }

  class << self
    def update_address(name, address)
      contract = find_or_initialize_by name: name
      contract.update!(address: address)
      contract
    end

    def numa
      find_by name: :numa
    end
  end

  def eth_contract
    @contract ||= begin
      file = File.read("#{Rails.root}/build/contracts/Numa.json")
      json = JSON.parse(file)
      abi = json['abi']
      bytecode = json['bytecode']
      client = Networker.get_client
      contract = Ethereum::Contract.create(client: client, abi: abi, code: bytecode, name: name, address: hash_address)
      contract.sender = '0x0000000000000000000000000000000000000000'
      contract
    end
  end
end
