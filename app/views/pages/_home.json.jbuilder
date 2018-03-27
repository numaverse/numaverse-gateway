json.messages messages do |message|
  json.partial! 'messages/show.json.jbuilder', message: message
end

if current_user
  json.current_user do
    json.partial! 'users/show.json.jbuilder', user: current_user
  end
end