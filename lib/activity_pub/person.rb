module ActivityPub
  class Person
    include ActivityPub::Helpers

    attr_reader :account

    def initialize(account)
      @account = account
    end

    def object_data
      {
        type: "Person",
        id: url_helpers.account_url(account.username || account.address),
        url: url_helpers.account_url(account.username || account.address),
        preferredUsername: account.username,
        address: account.hash_address,
        summary: account.bio,
        location: account.location,
        name: account.display_name,
        icon: icon,
        ipfs_hash: account.ipfs_hash,
      }
    end

    def icon
      {
        type: "Image",
        url: IpfsServer.image_url(account.avatar_ipfs_hash),
        ipfs_hash: account.avatar_ipfs_hash
      }
    end
  end
end