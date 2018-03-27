class Federated::Follow < ApplicationRecord
  belongs_to :from_account, foreign_key: 'from_account_id', class_name: 'Federated::Account'
  belongs_to :to_account, foreign_key: 'to_account_id', class_name: 'Federated::Account'


end
