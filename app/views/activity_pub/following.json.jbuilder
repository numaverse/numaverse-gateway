json.set! "@context", ActivityPub::ActivityStream.new(nil).context
json.id ap_following_url(account_id: @account.hash_address)
json.type "OrderedCollection"
json.totalItems @follows.total_count

json.orderedItems @follows.collect {|follow| follow.to_account.url_id }