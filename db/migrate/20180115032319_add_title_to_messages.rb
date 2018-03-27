class AddTitleToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :title, :string
    add_column :messages, :tldr, :text
    add_column :messages, :foreign_data_json, :json
    add_column :messages, :sanitized_body, :text
  end
end
