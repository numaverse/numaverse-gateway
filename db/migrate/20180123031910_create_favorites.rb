class CreateFavorites < ActiveRecord::Migration[5.1]
  def change
    create_table :favorites do |t|
      t.integer :user_id
      t.integer :message_id

      t.timestamps
    end

    add_column :messages, :favorites_count, :integer, default: 0
  end
end
