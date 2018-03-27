FactoryBot.define do
  factory :transaction do
    block_hash "MyString"
    block_number 1
    from "MyString"
    to "MyString"
    gas 1
    gas_price 1
    hash_address "MyString"
    nonce "MyString"
    input "MyText"
  end
end
