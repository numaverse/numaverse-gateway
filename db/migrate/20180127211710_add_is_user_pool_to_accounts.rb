class AddIsUserPoolToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :is_user_pool, :boolean, null: false, default: false
  end
end
