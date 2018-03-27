class CreateFollows < ActiveRecord::Migration[5.1]
  def change
    create_table :follows do |t|
      t.integer :from_user_id
      t.integer :to_user_id

      t.timestamps
    end
  end
end
