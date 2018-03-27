module ActivityPub
  class ActivityStream
    include ActivityPub::Helpers

    attr_reader :object

    def initialize(object)
      @object = object
    end
  end
end