FactoryBot.define do
  factory :federated_follow, class: 'Federated::Follow' do
    from_account { create(:federated_account) }
    to_account { create(:remote_account) }
  end
end
