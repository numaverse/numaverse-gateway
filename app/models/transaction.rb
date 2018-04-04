class Transaction < ApplicationRecord
  include HashAddressable

  validates_presence_of :address

  belongs_to :block, optional: true
  belongs_to :message, optional: true
  belongs_to :transactable, polymorphic: true, optional: true
  belongs_to :to_account, class_name: 'Account', foreign_key: 'to_account_id', optional: true
  belongs_to :from_account, class_name: 'Account', foreign_key: 'from_account_id', optional: true

  after_create :update_account_balances
  after_create :fetch_transaction_data, if: :pending?
  after_save :update_balances_if_new_block

  monetize :value_nuwei

  scope :by_block_number, -> {
    joins(:block).eager_load(:block).order('blocks.number desc')
  }

  class << self
    def make_by_address(address, data: nil)
      Transaction.transaction do
        tx = by_address(address)
        if data || tx.blank?
          tx ||= Transaction.new(address: address)
          tx.strip_0x
          data ||= tx.get_blockchain_info
          if data.present?
            tx.from_data(data)
          end
          tx.save!
        end
        tx
      end
    end
  end

  def from_data(tx)
    # ap tx
    assign_attributes(
      block_hash: tx['blockHash'],
      block_number: tx['blockNumber'].try(:from_hex),
      from: tx['from'],
      to: tx['to'],
      gas: tx['gas'].try(:from_hex),
      gas_price: tx['gasPrice'].try(:from_hex),
      address: tx['hash'],
      input: tx['input'],
      nonce: tx['nonce'],
      to_account: tx['to'].present? ? Account.make_by_address(tx['to']) : nil,
      from_account: tx['from'].present? ? Account.make_by_address(tx['from']) : nil,
      value_nuwei: tx['value'].try(:from_hex),
    )
    strip_0x
    self
  end

  def update_account_balances
    to_account.try(:update_balance)
    from_account.try(:update_balance)
  end

  def update_balances_if_new_block
    if saved_change_to_block_id? && block_id.present?
      update_account_balances
    end
  end

  def confirmations
    return nil if pending?
    Block.eth_block_number - block_number
  end

  def get_blockchain_info
    Hashie::Mash.new(Networker.get_client.eth_get_transaction_by_hash(hash_address)['result'])
  end

  def pending?
    block_number.blank?
  end

  def fetch_transaction_data
    FetchTransactionDataJob.set(perform_in: 10.seconds).perform_later(self)
  end
end
