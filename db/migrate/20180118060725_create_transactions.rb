class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.string :block_hash
      t.integer :block_number
      t.string :from
      t.string :to
      t.integer :gas
      t.integer :gas_price
      t.string :hash_address
      t.string :nonce
      t.text :input
      t.integer :to_account_id
      t.integer :from_account_id
      t.integer :block_id

      t.timestamps
    end
  end
end
