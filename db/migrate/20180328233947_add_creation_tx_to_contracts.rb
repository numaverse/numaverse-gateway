class AddCreationTxToContracts < ActiveRecord::Migration[5.1]
  def change
    add_column :contracts, :creation_tx_id, :integer
  end
end
