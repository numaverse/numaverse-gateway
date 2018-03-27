class Federated::Version < ApplicationRecord
  belongs_to :federated_message, class_name: "Federated::Message"
  validates_presence_of :object_changes, :action_type, :local_message_id

  after_save :deliver!

  scope :most_recent, -> { order("created_at desc") }

  enum action_type: {
    created: 0,
    updated: 1,
    deleted: 2,
  }

  def deliver!
    ActivityPub::DeliveryJob.perform_later(self)
  end
end
