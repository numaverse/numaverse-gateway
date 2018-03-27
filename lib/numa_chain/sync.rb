require './app/models/transaction'
module NumaChain
  class Sync
    class << self
      def all_blocks(min: nil)
        client = Networker.get_client
        Rails.logger.debug "Fetching block count"
        max = client.eth_block_number['result'].from_hex
        Rails.logger.debug "Current max block: #{max}"
        min = min || Block.order('number desc').first.try(:number) || -1
        puts (min+1..max)
        (min+1..max).each do |block_number|
          puts "Fetching block ##{block_number}"
          Block.sync_number(block_number)
        end
      end

      def users
        Rails.logger.debug "Syncing Users"
        events = Networker.users_events
        contract = Contract.users
        eth_contract = contract.eth_contract

        events.each do |event|
          address = event.topics.first
          account = Account.by_address(address) || Account.new(address: address)
          account = nil unless account.is_a?(Account)

          ipfs_hash = eth_contract.call.users(address).unpack('H*').first
          ipfs_hash = IpfsServer.data_to_hash(18, 32, ipfs_hash)

          begin
            json = IpfsServer.cat(ipfs_hash)
            username = json.preferredUsername.downcase
            if Account.where.not(id: account.id).where("lower(username) = ?", username).first.present?
              username = "#{username}_#{SecureRandom.hex(5)}"
            end
            account.confirm
            account.update!(
              username: username,
              bio: json.summary,
              display_name: json.name,
              avatar_ipfs_hash: json.try(:icon).try(:ipfs_hash),
              ipfs_hash: ipfs_hash
            )

            tx = Transaction.make_by_address(event.transactionHash)
            tx.update(transactable: account)

            contract.contract_events.create!(
              tx: tx,
              event_name: 'UserUpdated'
            )
          rescue => e
            Rails.logger.error(e)
          end
        end
      end

      def messages
        Rails.logger.debug "Syncing messages"
        process_message_events(Networker.message_created_events, name: 'MessageCreated')
        process_message_events(Networker.message_updated_events, name: 'MessageUpdated')
      end

      def process_message_events(events, name: )
        contract = Contract.messages
        eth_contract = contract.eth_contract

        events.each do |event|
          foreign_id = event.topics.first
          tx = Transaction.make_by_address(event.transactionHash)

          message_data = Networker.get_message(foreign_id, eth_contract)
          sender = Account.make_by_address(event.topics[1])

          begin
            transactable = tx.transactable
            Rails.logger.debug "Fetching IPFS hash: #{message_data.ipfs_hash}"
            json = IpfsServer.cat(message_data.ipfs_hash)
            Rails.logger.debug "Syncing object with type: #{json.type}"
            # ap json
            if json.type == "Follow"
              transactable = sync_follow(transactable, sender: sender, json: json, tx: tx, message_data: message_data)
            elsif json.type == "Like"
              transactable = sync_favorite(transactable, sender: sender, json: json, tx: tx, message_data: message_data)
            elsif json.type == "Tip"
              transactable = sync_tip(transactable, sender: sender, json: json, tx: tx, message_data: message_data)
            else
              transactable = sync_message(transactable, sender: sender, json: json, tx: tx, message_data: message_data)
            end

            transactable.confirm
            transactable.save
            contract.contract_events.create!(
              tx: tx,
              event_name: name
            )
          rescue => exception
            # Rails.logger.debug "Error when syncing "
            Rails.logger.error(exception)
          end
        end
      end

      def sync_follow(follow, sender: , json: , tx: , message_data: )
        follow ||= tx.from_account.from_follows.new
        to_account = Account.make_by_address(json.object.address)
        follow.update(
          ipfs_hash: message_data.ipfs_hash,
          foreign_id: message_data.foreign_id,
          to_account: to_account,
          hidden_at: json.hiddenAt,
        )
        tx.update(transactable: follow)
        follow
      end

      def sync_message(message, sender: , json: , tx: , message_data: )
        message ||= sender.messages.new
        if json.type == "Note"
          message.update_attributes(
            json_schema: :micro,
            body: json.plainTextContent,
            hidden_at: json.hiddenAt,
          )
        elsif json.type == "Article"
          message.update_attributes(
            json_schema: :article,
            body: json.plainTextContent,
            title: json.name,
            tldr: json.summary,
            hidden_at: json.hiddenAt,
          )
        end

        message.update(ipfs_hash: message_data.ipfs_hash, foreign_id: message_data.foreign_id)

        tx.update(transactable: message)
        message
      end

      def sync_favorite(favorite, sender: , json: , tx: , message_data: )
        favorite ||= tx.from_account.favorites.new
        message = Message.find_by(foreign_id: json.object.foreign_id) || Message.find_by(uuid: json.object.uuid)
        favorite.update(
          ipfs_hash: message_data.ipfs_hash,
          foreign_id: message_data.foreign_id,
          message: message,
          hidden_at: json.hiddenAt,
        )
        tx.update(transactable: favorite)
        favorite
      end

      def sync_tip(tip, sender: , json: , tx: , message_data: )
        tip ||= tx.from_account.from_tips.new
        to_account = Account.make_by_address(json.object.address)
        # tip_tx = Transaction.find_by(address: json.transactionHash)
        tip_tx = Transaction.make_by_address(json.transactionHash)
        tip_attrs = {
          tx: tip_tx,
          to_account: to_account,
          tx_hash: json.transactionHash,
          ipfs_hash: message_data.ipfs_hash,
          foreign_id: message_data.foreign_id,
        }
        to_message = Message.find_by(foreign_id: json.object.foreign_id) || Message.find_by(uuid: json.object.uuid)
        if to_message.present?
          tip_attrs[:to_message] = to_message
        end
        tip.update(tip_attrs)
        tx.update(transactable: tip)
        tip
      end

    end
  end
end