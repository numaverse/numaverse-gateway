FactoryBot.define do
  factory :federated_account, class: 'Federated::Account' do
    local_account { create(:account) }

    factory :remote_account do
      federated_id "http://localhost:3000/users/admin"
    end
  end
end
