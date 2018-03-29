class AddStateToBatches < ActiveRecord::Migration[5.1]
  def change
    add_column :batches, :aasm_state, :string
    add_column :batches, :ipfs_hash, :string
    add_column :batch_items, :batched_at, :datetime
    add_column :batch_items, :aasm_state, :string
    add_column :follows, :uuid, :string
    add_column :favorites, :uuid, :string
    add_column :tips, :uuid, :string
    add_column :batches, :uuid, :string
  end
end
