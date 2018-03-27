class AddTransactionsCountToBlocks < ActiveRecord::Migration[5.1]
  def change
    add_column :blocks, :transactions_count, :integer
  end
end
