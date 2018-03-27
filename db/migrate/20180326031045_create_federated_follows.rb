class CreateFederatedFollows < ActiveRecord::Migration[5.1]
  def change
    create_table :federated_follows do |t|
      t.string :federated_id
      t.integer :from_account_id
      t.integer :to_account_id

      t.timestamps
    end
  end
end
