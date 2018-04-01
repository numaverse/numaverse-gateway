class Account < ApplicationRecord
  include Uuidable
  include HashAddressable
  include ActivityStreamable

  validates_presence_of :address
  validates_uniqueness_of :is_user_pool, if: :is_user_pool
  validates :username, uniqueness: true, format: { with: /\A[a-z0-9][a-z0-9_]*\z/i }, allow_nil: true, case_sensitive: false

  has_many :messages
  has_many :transactions, as: :transactable
  has_many :from_transactions, class_name: "Transaction", foreign_key: :from_account_id
  has_many :to_transactions, class_name: "Transaction", foreign_key: :to_account_id
  has_many :favorites
  has_one :batch_item, as: :batchable
  has_many :federated_messages, class_name: 'Federated::Message', foreign_key: 'local_account_id'
  has_many :federated_message_versions, through: :federated_messages, source: 'versions'
  has_one :federated_account, class_name: 'Federated::Account', foreign_key: 'local_account_id'

  has_many :from_follows, class_name: "Follow", foreign_key: :from_account_id
  has_many :to_follows, class_name: "Follow", foreign_key: :to_account_id

  has_many :from_tips, class_name: "Tip", foreign_key: 'from_account_id'
  has_many :to_tips, class_name: "Tip", foreign_key: 'to_account_id'

  monetize :balance_nuwei

  class << self

    def user_pool
      find_by(is_user_pool: true)
    end

  end

  def following_messages(relation: nil)
    (relation || Message).where(account_id: following_account_ids)
  end

  def following_account_ids
    [id] + from_follows.visible.uniq.pluck('to_account_id')
  end

  def fetch_batch
    batch = Batch.where(account_id: id).where.not(aasm_state: [:confirmed, :pending]).first
    return batch if batch.present?
    Batch.create(account_id: id, aasm_state: 'batched')
  end

  def update_balance(save: true)
    self.balance_nuwei = fetch_balance
    self.save if save
  end

  def fetch_balance
    res = Networker.get_client.eth_get_balance(hash_address)
    res['result'].from_hex
  end

  def hidden_at
    nil
  end

  def smart_contract_args
    hash_function, hash_size, hex = IpfsServer.hash_data(ipfs_hash)
    [
      '0x'+hex,
    ]
  end

  def update_and_post(attributes)
    assign_attributes(attributes)
    is_changed = changed?
    return false unless save
    post_on_chain!
    true
  end

  def activity_stream
    ActivityPub::Person.new(self)
  end

  def update_federated_model
    fed_account = federated_account || Federated::Account.new(local_account: self)
    fed_account.update(
      object_data: activity_stream.object_data,
      username: username,
      display_name: display_name,
      local_account: self,
    )
    fed_account
  end

  def sender_account
    self
  end
end
