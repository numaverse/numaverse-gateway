json.id message.id
json.body message.body
json.account_id message.account_id
json.foreign_created_at message.foreign_created_at
json.foreign_block_created message.foreign_block_created
json.foreign_id message.foreign_id
json.foreign_data message.foreign_data
json.foreign_updated_at message.foreign_updated_at
json.foreign_block_updated message.foreign_block_updated
json.created_at message.created_at
json.updated_at message.updated_at
json.tx_data message.tx_data
json.tx_hash message.tx_hash
json.tx_id message.tx.try(:id)
json.title message.title
json.tldr message.tldr
json.foreign_data_json message.foreign_data_json
json.sanitized_body message.sanitized_body
json.user_id message.user_id
json.uuid message.uuid
json.hidden_at message.hidden_at
json.favorites_count message.favorites_count
json.repost_id message.repost_id
json.repost_count message.repost_count
json.reply_count message.reply_count
json.reply_to_id message.reply_to_id
json.ipfs_hash message.ipfs_hash
json.json_schema message.json_schema
json.json_schema_other message.json_schema_other
json.aasm_state message.aasm_state

json.tips humanized_money_with_symbol message.tips_sum
json.tips_sum message.tips_sum.to_f

# json.avatar (message.user || User.new).avatar.url(:medium)
json.sender message.account.address
json.timestamp message.foreign_created_at || message.created_at

json.is_favorited current_account && current_account.favorites.where(message: message).exists?
json.is_reposted current_account && message.reposts.where(account: current_account).exists?
json.is_replied current_account && message.replies.where(account: current_account).exists?
json.is_tipped current_account && ((message.account == current_account) || message.tips.where(from_account: current_account).exists?)

json.onebox message.onebox

json.is_loading false

if message.account
  json.account do
    json.partial! 'accounts/show.json.jbuilder', account: message.account
  end
end