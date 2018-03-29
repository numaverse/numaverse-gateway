module ActivityPub
  class Follow < ActivityPub::ActivityStream
    def object_data
      {
        type: "Follow",
        actor: person(object.from_account),
        object: person(object.to_account),
        id: url_helpers.follow_url(object),
        uuid: object.uuid,
        hiddenAt: object.hidden_at,
      }
    end
  end
end