class CreateBatchItems < ActiveRecord::Migration[5.1]
  def change
    create_table :batch_items do |t|
      t.integer :batch_id
      t.string :batchable_type
      t.integer :batchable_id

      t.timestamps
    end
  end
end
