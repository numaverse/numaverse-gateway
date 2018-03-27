class AddRepostToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :repost_id, :integer
    add_column :messages, :repost_count, :integer, default: 0
  end
end
