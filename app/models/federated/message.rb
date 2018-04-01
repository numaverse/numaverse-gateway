class Federated::Message < ApplicationRecord
  belongs_to :local_message, foreign_key: 'local_message_id', class_name: 'Message', optional: true
  belongs_to :local_account, foreign_key: 'local_account_id', class_name: 'Account', optional: true
  belongs_to :federated_account, foreign_key: 'federated_account_id', class_name: 'Federated::Account', optional: true
  has_many :versions, foreign_key: 'federated_message_id', class_name: 'Federated::Version'

  after_create :create_version, if: :local?
  before_update :update_versions, if: :local?

  scope :visible, -> { where('hidden_at is null')}
  scope :remote, -> { where('local_message_id is null') }

  def local?
    local_message_id.present?
  end

  def create_version
    versions.create(object_changes: object_data, action_type: :created, local_message_id: local_message_id)
  end

  def update_versions
    if object_data_changed?
      changes = {}
      (object_data_was.keys + object_data.keys).uniq.each do |key|
        if object_data_was[key] != object_data[key]
          changes[key] = object_data[key]
        end
      end
      return true if changes.blank?
      versions.create(object_changes: changes, action_type: :updated, local_message_id: local_message_id)
    end
  end
end
