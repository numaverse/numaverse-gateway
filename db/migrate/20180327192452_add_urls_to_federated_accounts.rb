class AddUrlsToFederatedAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :federated_accounts, :shared_inbox_url, :string
    add_column :federated_accounts, :inbox_url, :string
    add_column :federated_accounts, :outbox_url, :string
    add_column :federated_accounts, :followers_url, :string
    add_column :federated_accounts, :following_url, :string
  end
end
