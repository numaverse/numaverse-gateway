# json.set! "@context", ActivityPub::ActivityStream.new(nil).context
json.merge! @account.activity_stream.data
json.id ap_account_url(@account.hash_address)
json.outbox ap_outbox_url(@account.hash_address)
json.inbox ap_inbox_url(@account.hash_address)
json.followers ap_followers_url(@account.hash_address)

json.publicKey do
  json.id ap_account_url(@account.hash_address, anchor: 'main-key')
  json.owner ap_account_url(@account.hash_address)
  json.publicKeyPem @account.federated_account.public_key
end