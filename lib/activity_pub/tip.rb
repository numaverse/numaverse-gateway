module ActivityPub
  class Tip < ActivityPub::ActivityStream
    def object_data
      data = {
        type: "Tip",
        actor: person(object.from_account),
        object: person(object.to_account),
        uuid: object.uuid,
        valueNuwei: object.tx.value_nuwei,
        transactionHash: object.tx.hash_address,
      }
      if object.to_message.present?
        data[:toMessage] = ActivityPub::Message.new(object.to_message).object_data
      end
      if object.message.present?
        data[:fromMessage] = ActivityPub::Message.new(object.message).object_data
      end
      data
    end
  end
end