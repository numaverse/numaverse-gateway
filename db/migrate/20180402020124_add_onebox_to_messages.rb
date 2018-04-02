class AddOneboxToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :onebox, :text
  end
end
