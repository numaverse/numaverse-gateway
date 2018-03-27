FactoryBot.define do
  factory :message do
    body { Faker::Lorem.sentence }
    account { create(:account_with_data )}
    # dat_folder_id { SecureRandom.hex(32) }
    json_schema :micro

    factory :article do
      json_schema :article
      body do
        str = "# #{Faker::Lorem.sentence}\n\n"
        str += Faker::Lorem.paragraphs.join("\n\n")
      end
      tldr { Faker::Lorem.sentence }
      title { Faker::Lorem.sentence }
    end
  end
end
