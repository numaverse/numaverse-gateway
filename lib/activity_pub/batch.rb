module ActivityPub
  class Batch < ActivityPub::ActivityStream
    def object_data
      {
        totalSize: items.size,
        orderedItems: items.collect(&:ipfs_object_data)
      }
    end   

    def items
      @items ||= object.batchables
    end
  end
end