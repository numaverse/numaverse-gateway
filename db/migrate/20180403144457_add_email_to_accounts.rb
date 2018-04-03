class AddEmailToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :email, :string
  end
end
