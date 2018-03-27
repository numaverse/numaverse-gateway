FactoryBot.define do
  factory :follow do
    from_account { create(:account) }
    to_account { create(:account) }
  end
end
