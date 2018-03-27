class AddTransactableToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :transactable_id, :integer
    add_column :users, :transactable_type, :string
  end
end
