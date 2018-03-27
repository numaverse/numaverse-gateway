class AddIpfsDataToFollows < ActiveRecord::Migration[5.1]
  def change
    add_column :follows, :ipfs_hash, :string
    add_column :follows, :foreign_id, :integer
    add_column :follows, :hidden_at, :datetime

    add_column :favorites, :ipfs_hash, :string
    add_column :favorites, :foreign_id, :integer
    add_column :favorites, :hidden_at, :datetime

    add_column :tips, :ipfs_hash, :string
    add_column :tips, :foreign_id, :integer

    add_column :favorites, :account_id, :integer
    remove_column :favorites, :user_id, :integer

    rename_column :messages, :uid, :uuid
  end
end
