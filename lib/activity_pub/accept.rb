module ActivityPub
  class Accept < ActivityPub::ActivityStream
    def object_data
      {
        type: 'Accept',
        object: {
          type: 'Follow',
          id: object.federated_id,
          actor: object.from_account.url_id,
          object: object.to_account.url_id,
        }
      }
    end
  end
end