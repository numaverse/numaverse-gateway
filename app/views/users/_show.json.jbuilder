json.avatar do
  json.medium user.avatar.url(:medium)
  json.thumb user.avatar(:thumb)
end
json.username user.username
json.address '0x'+user.managed_account.address
json.location user.location
json.bio user.bio
json.balance humanized_money_with_symbol user.managed_account.balance
json.balance_nuwei user.balance_nuwei.to_s
json.id user.id

json.account do
  json.partial! 'accounts/show.json.jbuilder', locals: { account: user.managed_account }
end