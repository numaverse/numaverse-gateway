class AddPrivateHexToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :encrypted_private_hex, :string
    add_column :accounts, :encrypted_private_hex_iv, :string
  end
end
