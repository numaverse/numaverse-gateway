class ContractEvent < ApplicationRecord
  belongs_to :contract
  belongs_to :tx, class_name: "Transaction"
  belongs_to :message, optional: true

  validates_presence_of :event_name
end
