class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :account, foreign_key: true
      t.datetime :foreign_created_at
      t.integer :foreign_block_created
      t.integer :foreign_id
      t.text :foreign_data
      t.datetime :foreign_updated_at
      t.integer :foreign_block_updated

      t.timestamps
    end
  end
end
