class AddLocalMessageIdToVersions < ActiveRecord::Migration[5.1]
  def change
    add_column :federated_versions, :local_message_id, :integer
  end
end
