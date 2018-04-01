namespace :contracts do
  task create: :environment do
    puts "Updating contract address"
    if ENV['CHAIN_ID'] == '1'
      puts "Updated mainnet contract"
      contract_address = '0x0bec4767cd170242895d244d7ff73feaff6c2598'
      creation_tx = Transaction.make_by_address('0x905ed2a08464d37a0541f04c64c60f417cd93591044b4d8603e972ffe2c85e1d')
      Contract.update_address :numa, contract_address, creation_tx
      creation_tx.update(to_account: Account.make_by_address(contract_address))
    elsif ENV['CHAIN_ID'] == '3'
      puts "Updated Ropsten contract"
      contract_address = '0x2096bbcb8814ef7af4f49ad793d3fc311f5cfba6'
      creation_tx = Transaction.make_by_address('0x3441f372f1384fbe6010688e0e2043aefbc93f9fcc4cb95f5f287ce80cfb994e')
      Contract.update_address :numa, contract_address, creation_tx
      creation_tx.update(to_account: Account.make_by_address(contract_address))
    end
  end
end