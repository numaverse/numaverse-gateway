class CreateBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :blocks do |t|
      t.string :hash_address
      t.string :miner
      t.string :nonce
      t.datetime :timestamp
      t.integer :number
      t.integer :difficulty
      t.integer :size
      t.integer :gas_limit
      t.integer :gas_used

      t.timestamps
    end
  end
end
