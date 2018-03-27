class ActivityPub::InboxFactoryJob < ApplicationJob
  queue_as :default

  def perform(from_account, to_account, body)
    json = Hashie::Mash.new(JSON.parse(body))
    # ap json
    if json.type == "Follow"
      follow = from_account.from_follows.find_or_initialize_by(to_account: to_account)
      follow.update!(federated_id: json.id)
      follow.accept!
    elsif json.type == 'Undo'
      object = json.object
      if object.type == 'Follow'
        follow = Federated::Follow.find_by(federated_id: object.id)
        follow.try(:destroy)
      end
    end
  end
end
