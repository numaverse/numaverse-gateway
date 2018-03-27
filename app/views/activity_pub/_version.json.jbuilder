json.id Rails.application.routes.url_helpers.ap_activity_url(version.id)
json.type version.action_type.chop.capitalize
json.published version.created_at
json.to ["https://www.w3.org/ns/activitystreams#Public"]

json.actor Rails.application.routes.url_helpers.ap_account_url(account_id: account.hash_address)
json.object do
  json.merge! version.object_changes.except('actor')
  json.id Rails.application.routes.url_helpers.ap_message_url(version.federated_message_id)
  json.url Rails.application.routes.url_helpers.message_url(version.local_message_id)
  json.to ["https://www.w3.org/ns/activitystreams#Public"]
end

