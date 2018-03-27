module ActivityPub
  class Favorite < ActivityPub::ActivityStream
    def object_data
      {
        type: "Like",
        actor: person(object.account),
        object: ActivityPub::Message.new(object.message).object_data,
        hiddenAt: object.hidden_at,
      }
    end
  end
end