FactoryBot.define do
  factory :federated_account, class: 'Federated::Account' do
    local_account_id 1
    object_data ""
    federated_id "MyString"
    public_key "MyText"
    private_key "MyText"
    username "MyString"
    avatar_url "MyString"
  end
end
