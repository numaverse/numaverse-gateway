# json.("@context" ActivityPub::ActivityStream.new(nil).context)
# json.send("@context")
json.set! "@context", ActivityPub::ActivityStream.new(nil).context
json.id ap_outbox_url(account_id: @account.hash_address)
json.type "OrderedCollection"
json.totalItems @versions.total_count

json.orderedItems @versions do |version|
  json.partial! "activity_pub/version.json.jbuilder", locals: { version: version, account: @account }
end