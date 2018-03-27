json.user do
  json.partial! 'show.json.jbuilder', user: user
end
json.messages messages do |message|
  json.partial! 'messages/show.json.jbuilder', message: message
end