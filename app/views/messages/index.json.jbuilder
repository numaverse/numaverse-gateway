json.messages @messages do |message|
  json.partial! 'messages/show.json.jbuilder', message: message
end

json.finished @messages.last_page?