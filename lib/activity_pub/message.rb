module ActivityPub
  class Message < ActivityPub::ActivityStream
    def object_data
      send("#{object.json_schema}_data")
    end

    def article_data
      {
        type: "Article",
        name: object.title,
        summary: object.tldr,
      }.merge(message_data)
    end

    def micro_data
      {
        type: "Note",
      }.merge(message_data)
    end

    def message_data
      actor = ActivityPub::Person.new(object.account).object_data
      {
        content: object.sanitized_body,
        id: url_helpers.message_url(object.id),
        ipfs_hash: object.ipfs_hash,
        foreign_id: object.foreign_id,
        actor: actor,
        plainTextContent: object.body,
        uuid: object.uuid,
        hiddenAt: object.hidden_at,
      }
    end
  end
end