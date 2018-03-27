json.set! "@context", ActivityPub::ActivityStream.new(nil).context
json.id ap_followers_url(account_id: @account.hash_address)
json.type "OrderedCollection"
json.totalItems @follows.total_count

follower_ids = @follows.collect do |follow|
  from_account = follow.from_account
  if from_account.local?
    ap_account_url(Account.find(from_account.local_account_id).hash_address)
  else
    from_account.federated_id
  end
end
json.orderedItems follower_ids