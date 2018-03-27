FactoryBot.define do
  factory :federated_message, class: 'Federated::Message' do
    local_message { create(:message) }
  end
end
