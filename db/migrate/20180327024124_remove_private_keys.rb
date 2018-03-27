class RemovePrivateKeys < ActiveRecord::Migration[5.1]
  def change
    remove_column :accounts, :encrypted_private_hex, :string
    remove_column :accounts, :encrypted_private_hex_iv, :string

    drop_table :users
  end
end
