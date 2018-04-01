class Contract < ApplicationRecord
  include HashAddressable
  has_many :contract_events
  belongs_to :creation_tx, class_name: "Transaction"

  validates_presence_of :name
  validates_uniqueness_of :name

  enum name: {
    numa: 2,
  }

  class << self
    def update_address(name, address, creation_tx)
      contract = find_or_initialize_by name: name
      contract.update!(address: address, creation_tx: creation_tx)
      contract
    end

    def numa
      find_by name: :numa
    end
  end
end
