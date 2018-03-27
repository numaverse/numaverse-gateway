class AddTxDataToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :tx_data, :json
    add_column :messages, :tx_hash, :string
  end
end
