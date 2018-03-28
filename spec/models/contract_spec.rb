require 'rails_helper'

RSpec.describe Contract, type: :model do
  it 'initializes the right contract', :end_to_end do
    contract = Contract.numa.eth_contract
    expect(contract.address).to eql(Contract.numa.hash_address)
    expect(contract.call).to respond_to(:users)
  end
end
