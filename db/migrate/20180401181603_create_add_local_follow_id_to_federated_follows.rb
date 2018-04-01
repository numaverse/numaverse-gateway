class CreateAddLocalFollowIdToFederatedFollows < ActiveRecord::Migration[5.1]
  def change
    add_column :federated_follows, :local_follow_id, :integer
    add_column :federated_follows, :hidden_at, :datetime
    add_column :federated_messages, :hidden_at, :datetime
  end
end
