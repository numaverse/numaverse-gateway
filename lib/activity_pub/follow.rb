module ActivityPub
  class Follow < ActivityPub::ActivityStream
    def object_data
      {
        type: "Follow",
        actor: object.from_account.try(:url_id) || person(object.from_account),
        object: object.to_account.try(:url_id) || person(object.to_account),
        id: url_helpers.follow_url(object),
        uuid: object.try(:uuid),
        hiddenAt: object.try(:hidden_at),
      }
    end
  end
end