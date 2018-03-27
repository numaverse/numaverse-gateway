class AddIpfsHashToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :ipfs_hash, :string
  end
end
