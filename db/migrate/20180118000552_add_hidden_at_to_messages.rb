class AddHiddenAtToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :hidden_at, :datetime
  end
end
