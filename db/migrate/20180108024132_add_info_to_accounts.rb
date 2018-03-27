class AddInfoToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :username, :string
    add_column :accounts, :uuid, :string

    add_column :users, :uuid, :string
  end
end
