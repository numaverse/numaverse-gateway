FactoryBot.define do
  factory :federated_follow, class: 'Federated::Follow' do
    federated_id "MyString"
    from_account_id 1
    to_account_id 1
  end
end
