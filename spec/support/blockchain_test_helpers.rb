module BlockchainTestHelpers
  def user_pool_account
    get_eth_account(0)
  end

  def deploy_contracts!
    NumaChain::Deploy.deploy!
  end

  def account_with_balance(balance: 1000)
    account = make_eth_account
    transfer_eth(user_pool_account, account, balance)
    account
  end

  def make_eth_account(opts={})
    address = Networker.get_client.personal_new_account('password')['result']
    account = create(:account_with_data, opts.merge(address: address))
    res = Networker.get_client.personal_unlock_account(address, 'password')
    account
  end

  def get_eth_account(index)
    address = Networker.get_client.eth_accounts['result'][index]
    account = Account.make_by_address(address)
    account.update_balance
    account
  end

  def post_message_on_chain(message)
    contract = Contract.numa
    return false unless contract

    message.post_on_ipfs
    if message.foreign_id
      encoded = js_sign('updateMessage', [message.foreign_id] + message.smart_contract_args)
    else
      encoded = js_sign('createMessage', message.smart_contract_args)
    end

    tx_hash = Networker.get_client.eth_send_transaction({
      from: message.sender_account.hash_address,
      to: contract.hash_address,
      data: encoded,
      gasPrice: 0.to_hex
    })['result']

    tx_data = Networker.get_client.eth_get_transaction_by_hash(tx_hash)['result']
    tx = Transaction.new
    tx.from_data(Hashie::Mash.new(tx_data))
    tx.transactable = message
    tx.save!
    tx
  end

  def js_sign(func, args)
    signed_hex = `node app/javascript/signer.js #{func} #{args.join(' ')}`.strip;

    signed_hex.split("\n").last
  end

  def sign_in_account(account)
    request.session[:account_id] = account.id
  end
  
  def transfer_eth(from, to, value)
    if (value <= 0) || (from.balance_nuwei < value)
      raise "Invalid value"
    end
    client = Networker.get_client
    tx_hash = client.eth_send_transaction(from: from.hash_address, to: to.hash_address, value: value.to_hex, gasPrice: 0.to_hex)['result']

    tx_info = Hashie::Mash.new(client.eth_get_transaction_by_hash(tx_hash)['result'])
    tx = Transaction.new
    tx.from_data(tx_info)
    tx.save!
    
    to.balance_nuwei += value
    to.save
    from.balance_nuwei -= value
    from.save
    
    tx
  end

  def tip(to, value, to_message=nil)
    tx = transfer(to, value)
    tip = from_tips.build(
      to_account: to,
      tx_id: tx.id,
      tx_hash: tx.hash_address
    )
    if to_message
      tip.to_message = to_message
    end
    tip.save!
    tip
  end

  def post_account_on_chain(account)
    contract = Contract.numa
    return false unless contract

    account.post_on_ipfs
    encoded = js_sign('updateUser', account.smart_contract_args)

    tx_hash = Networker.get_client.eth_send_transaction({
      from: account.hash_address,
      to: contract.hash_address,
      data: encoded,
      gasPrice: 0.to_hex
    })['result']

    tx_data = Networker.get_client.eth_get_transaction_by_hash(tx_hash)['result']
    tx = Transaction.new
    tx.from_data(Hashie::Mash.new(tx_data))
    tx.transactable = account
    tx.save!
    tx
  end
end