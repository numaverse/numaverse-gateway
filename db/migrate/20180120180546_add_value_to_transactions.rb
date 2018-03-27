class AddValueToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_monetize :transactions, :value
    change_column :transactions, :gas_price, :decimal, precision: 32, scale: 0
  end
end
