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
    Networker.get_contract(name.to_s.capitalize, address: hash_address)
  end
end
