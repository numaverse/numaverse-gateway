class AddTransactableToTransactions < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :transactable_id, :integer
    add_column :transactions, :transactable_type, :string
  end
end
