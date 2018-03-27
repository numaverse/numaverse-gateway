class CreateFederatedAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :federated_accounts do |t|
      t.integer :local_account_id
      t.json :object_data
      t.string :federated_id
      t.text :public_key
      t.text :private_key
      t.string :username
      t.string :avatar_url
      t.string :display_name

      t.timestamps
    end
  end
end
