json.subject params[:resource]
json.aliases [ account_url(@account.hash_address) ]
json.links [
  {
    rel: 'self',
    type: 'application/activity+json',
    href: ap_account_url(@account.hash_address)
  }
]