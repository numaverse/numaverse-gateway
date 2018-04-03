json.extract! account, :id, :address, :balance_nuwei, :username, :bio, :location, :display_name, :hash_address,
  :ipfs_hash, :avatar_ipfs_hash, :aasm_state

json.username_or_address account.username.present? ? "@#{account.username}" : account.hash_address

json.avatar do
  json.medium account_avatar(account, size: :medium)
  json.large account_avatar(account, size: :large)
  json.thumb account_avatar(account, size: :thumb)
end

json.balance humanized_money_with_symbol account.balance