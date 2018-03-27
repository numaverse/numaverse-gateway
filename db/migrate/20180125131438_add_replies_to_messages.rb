class AddRepliesToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :reply_count, :integer, default: 0
    add_column :messages, :reply_to_id, :integer
  end
end
