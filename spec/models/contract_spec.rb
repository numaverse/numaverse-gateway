require 'rails_helper'

RSpec.describe Contract, type: :model do
  it 'finds the Numa contract', :end_to_end do
    expect(Contract.find_by(name: :numa)).to eql(Contract.numa)
  end
end
