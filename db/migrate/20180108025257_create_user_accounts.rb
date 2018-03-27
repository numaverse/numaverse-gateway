class CreateUserAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :user_accounts do |t|
      t.integer :account_id
      t.integer :user_id
      t.string :uuid

      t.timestamps
    end
  end
end
