class AddJsonSchemaToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :json_schema, :integer
    add_column :messages, :json_schema_other, :string
  end
end
