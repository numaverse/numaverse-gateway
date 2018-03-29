class UpdateBlockNumberLimit < ActiveRecord::Migration[5.1]
  def change
    change_column :blocks, :number, :integer, limit: 8
    change_column :transactions, :block_number, :integer, limit: 8
  end
end
