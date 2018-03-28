class Transaction < ApplicationRecord
  include HashAddressable

  validates_presence_of :from, :gas, :gas_price, :input, :nonce, :address

  belongs_to :block, optional: true
  belongs_to :message, optional: true
  belongs_to :transactable, polymorphic: true, optional: true
  belongs_to :to_account, class_name: 'Account', foreign_key: 'to_account_id', optional: true
  belongs_to :from_account, class_name: 'Account', foreign_key: 'from_account_id', optional: true

  after_create :update_account_balances
  after_save :update_balances_if_new_block
  after_save :update_block_info

  monetize :value_nuwei

  scope :by_block_number, -> {
    joins(:block).eager_load(:block).order('blocks.number desc')
  }

  class << self
    def make_by_address(address)
      Transaction.transaction do
        tx = by_address(address)
        if tx.blank?
          tx = Transaction.new(address: address)
          tx.strip_0x
          # puts tx.address
          data = tx.get_blockchain_info
          tx.from_data(data)
          tx.save!
          tx.update_block_info(info: data)
          tx.save
        end
        tx
      end
    end
  end

  def from_data(tx)
    # ap tx
    assign_attributes(
      block_hash: tx.blockHash,
      block_number: tx.blockNumber.try(:from_hex),
      from: tx.from,
      to: tx.to,
      gas: tx.gas.try(:from_hex),
      gas_price: tx.gasPrice.try(:from_hex),
      address: tx['hash'],
      input: tx.input,
      nonce: tx.nonce,
      to_account: tx.to.present? ? Account.make_by_address(tx.to) : nil,
      from_account: tx.from.present? ? Account.make_by_address(tx.from) : nil,
      value_nuwei: tx.value.from_hex
    )
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
    last_block = Block.last_block_number
    number = block.try(:number)
    return -1 if number.blank?
    last_block - number
  end

  def update_block_info(info: nil)
    if block.blank?
      info ||= get_blockchain_info
      if number = info.blockNumber.try(:from_hex)
        Block.sync_number(number)
      end
    end
  end

  def get_blockchain_info
    Hashie::Mash.new(Networker.get_client.eth_get_transaction_by_hash(hash_address)['result'])
  end
end
