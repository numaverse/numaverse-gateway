class AddBalanceToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_monetize :accounts, :balance
  end
end
