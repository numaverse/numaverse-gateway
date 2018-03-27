class RenameTransactionAddress < ActiveRecord::Migration[5.1]
  def change
    rename_column :transactions, :hash_address, :address
    rename_column :blocks, :hash_address, :address
  end
end
