class CreateFederatedVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :federated_versions do |t|
      t.integer :action_type
      t.integer :federated_message_id
      t.json :object_changes

      t.timestamps
    end
  end
end
