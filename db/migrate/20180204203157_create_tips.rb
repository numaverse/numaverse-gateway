class CreateTips < ActiveRecord::Migration[5.1]
  def change
    create_table :tips do |t|
      t.integer :tx_id
      t.string :tx_hash
      t.integer :message_id
      t.integer :to_account_id
      t.integer :from_account_id
      t.integer :to_message_id

      t.timestamps
    end
  end
end