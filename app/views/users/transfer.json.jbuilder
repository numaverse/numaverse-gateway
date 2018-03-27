json.current_user do
  json.partial! 'users/show', user: current_user
end

json.to_user do
  json.partial! 'users/show', user: @user
end

json.transaction do
  json.id @transaction.id
  json.url transaction_url(@transaction)
  json.hash @transaction.hash_address
  json.value @transaction.value
  json.humanized_value humanized_money_with_symbol @transaction.value
end

if @tip
  json.tip do
    json.id @tip.id
    json.value @tip
    json.message_tips_sum humanized_money_with_symbol @tip.to_message.reload.tips_sum
  end
end