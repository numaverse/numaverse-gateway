FactoryBot.define do
  factory :account do
    after(:build) do |account|
      account.address = Eth::Key.new.address if account.address.blank?
    end

    factory :account_with_data do
      username { Faker::Internet.user_name.gsub(".","_") }
      display_name { Faker::Name.name }
      bio { Faker::Company.catch_phrase }
      avatar_ipfs_hash { 'Qm' + SecureRandom.hex(22) }
      email { Faker::Internet.email }
    end
    
    factory :confirmed_account, parent: :account_with_data do
      after(:create) do |account|
        account.confirm!
      end
    end

    factory :transacted_account, parent: :account_with_data do
      after(:create) do |account|
        account.transact!
      end
    end
  end
end
