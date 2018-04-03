class AddFederatedIdToFederatedMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :federated_messages, :federated_id, :string
  end
end
