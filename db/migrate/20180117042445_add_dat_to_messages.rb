class AddDatToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :dat_folder_id, :string
    add_column :messages, :uid, :string
  end
end
