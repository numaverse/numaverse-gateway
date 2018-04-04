json.messages @messages do |message|
  json.object_data message.object_data
  json.account do
    account = message.federated_account
    json.merge! account.object_data
    json.username account.username
    json.url account.object_data['url']
    json.avatar_url account.avatar_url || default_avatar(size: :thumb)
    json.federated_id account.federated_id
  end
  json.id message.id
end

json.federated_follows_size @from_follow_ids.size
json.per_page @messages.limit_value
json.finished @messages.last_page?