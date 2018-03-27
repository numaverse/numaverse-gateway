class AddLocationToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :location, :string
  end
end
