json.partial! 'messages/message.json.jbuilder', message: message
if message.repost_id.present?
  json.repost do
    json.partial! 'messages/message.json.jbuilder', message: message.repost
  end
end
if message.reply_to_id.present?
  json.reply_to do
    json.partial! 'messages/message.json.jbuilder', message: message.reply_to
  end
end
if defined?(replies)
  json.replies replies do |reply|
    json.partial! 'messages/show.json.jbuilder', message: reply 
  end
end

if defined?(tips)
  json.tips_list tips do |tip|
    json.sender tip.from_account.hash_address
    json.tx_id tip.tx_id
    json.username tip.from_account.try(:username)
    json.humanized_value humanized_money_with_symbol tip.value
    json.value tip.value.to_f
  end
end

if message.tip.present?
  tip = message.tip
  json.tip do
    json.tx_id tip.tx_id
    json.humanized_value humanized_money_with_symbol tip.value
    json.tx_url transaction_path(tip.tx)
    json.value tip.value.to_f
    json.to_message do
      json.partial! 'messages/message.json.jbuilder', message: tip.to_message
    end
  end
end