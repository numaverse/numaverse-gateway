require './app/models/transaction'
module NumaChain
  class Sync
    class << self

      def sync!
        client = Networker.get_client
        contract = Contract.stateless_numa
        contract_account = Account.make_by_address(contract.hash_address)
        min_block_num = contract_account.to_transactions.maximum('block_number')
        max_block_num = client.eth_block_number['result'].from_hex
        (min_block_num..max_block_num).each do |block_number|
          Rails.logger.info("Syncing block ##{block_number}")
          block = client.eth_get_block_by_number(block_number, true)['result']

          block['transactions'].each do |transaction|
            next if transaction['to'].blank? || transaction['to'].casecmp(contract.hash_address) != 0
            tx = Transaction.make_by_address(transaction['hash'], data: transaction)
            res = JSON.parse(`node app/javascript/commands/decode-transaction #{tx.input}`)
            hash = res['params'].first['value'][2..-1]
            ipfs_hash = IpfsServer.data_to_hash(18, 32, hash)
            process_batch(tx, ipfs_hash)
          end
        end
      end

      def process_batch(tx, ipfs_hash)
        sender = tx.from_account
        begin
          json = IpfsServer.cat(ipfs_hash)
          json.orderedItems.each do |item|
            if item.type == "Person"
              process_account(tx, item)
            elsif ['Note','Article'].include?(item.type)
              process_message(tx, item)
            elsif item.type == "Follow"
              process_follow(tx, item)
            elsif item.type == "Like"
              process_favorite(tx, item)
            end
          end
          begin
            batch = Batch.find_by!(uuid: json.uuid, account_id: sender.id)
          rescue ActiveRecord::RecordNotFound
            batch = sender.fetch_batch
          end
          tx.update(transactable: batch)
          batch.confirm!
        rescue => e
          raise e if Rails.env.test?
          Raven.capture_exception(e)
          Rails.logger.error(e.backtrace[0..5].join("\n"))
          Rails.logger.error(e)
        end
      end

      def process_account(tx, json)
        account = tx.from_account
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
        )
      end

      def process_message(tx, json)
        message = tx.from_account.messages.find_or_initialize_by(uuid: json.uuid)
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
        message.confirm!
        message
      end

      def process_follow(tx, json)
        follow = tx.from_account.from_follows.find_or_initialize_by(uuid: json.uuid)
        to_account = Account.make_by_address(json.object.address)
        follow.update(
          to_account: to_account,
          hidden_at: json.hiddenAt,
        )
        follow.confirm!
        follow
      end

      def process_favorite(tx, json)
        favorite = tx.from_account.favorites.find_or_initialize_by(uuid: json.uuid)
        message = Message.find_by(uuid: json.object.uuid)
        favorite.update(
          message: message,
          hidden_at: json.hiddenAt,
        )
        favorite.confirm!
        favorite
      end

      def process_user_update(tx, ipfs_hash)
        account = tx.from_account

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

          tx.update(transactable: account)

          Contract.numa.contract_events.create!(
            tx: tx,
            event_name: 'UserUpdated'
          )
        rescue => e
          Rails.logger.error(e.backtrace[0..5].join("\n"))
          Rails.logger.error(e)
        end
      end

      def process_event(tx, foreign_id, ipfs_hash)
        message_data = Hashie::Mash.new({foreign_id: foreign_id, ipfs_hash: ipfs_hash})
        sender = tx.from_account

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
          Contract.numa.contract_events.create!(
            tx: tx,
            event_name: name
          )
        rescue => exception
          # Rails.logger.debug "Error when syncing "
          puts exception
          Rails.logger.error(exception.backtrace[0..5].join("\n"))
          Rails.logger.error(exception)
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