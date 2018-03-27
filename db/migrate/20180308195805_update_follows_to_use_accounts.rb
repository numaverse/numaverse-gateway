class UpdateFollowsToUseAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :follows, :to_account_id, :integer
    add_column :follows, :from_account_id, :integer

    remove_column :follows, :to_user_id, :integer
    remove_column :follows, :from_user_id, :integer
  end
end
