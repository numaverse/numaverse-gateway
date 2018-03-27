class AddMessageIdToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :message_id, :integer
  end
end
