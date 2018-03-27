class CreateFederatedMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :federated_messages do |t|
      t.integer :local_account_id
      t.integer :federated_account_id
      t.json :object_data
      t.integer :local_message_id

      t.timestamps
    end
  end
end
