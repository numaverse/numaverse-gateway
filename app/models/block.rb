class Block < ApplicationRecord
  validates_presence_of :difficulty, :gas_limit, :gas_used, :address, :miner, 
    :nonce, :number, :size, :timestamp

  has_many :transactions

  class << self
    def last_block_number
      order('number desc').first.try(:number) || 0
    end

    def sync_number(block_number)
      bd = Hashie::Mash.new(Networker.get_client.eth_get_block_by_number(block_number, true)['result'])
      # ap bd
      block = Block.find_or_initialize_by(number: block_number)
      block.assign_attributes(
        difficulty: bd.difficulty.from_hex,
        gas_limit: bd.gasLimit.from_hex,
        gas_used: bd.gasUsed.from_hex,
        address: bd['hash'],
        miner: bd.miner,
        nonce: bd.nonce,
        size: bd['size'].from_hex,
        timestamp: Time.at(bd.timestamp.from_hex),
      )
      block.save!
      bd.transactions.each do |transaction|
        t = Transaction.by_address(transaction['hash']) || block.transactions.new
        t.block = block
        t.from_data(transaction)
        t.save!
      end
    rescue => e
      puts e.message
      puts e.backtrace
      Rails.logger.error(e)
    end

    def eth_block_number
      Rails.cache.fetch('eth_block_number', {expires_in: 1.minute, race_condition_ttl: 10.seconds}) do
        Networker.get_client.eth_block_number['result'].from_hex
      end
    end
  end
end
