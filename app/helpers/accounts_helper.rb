module AccountsHelper
  def link_to_account(account)
    if account.blank?
      nil
    elsif account.hash_address.downcase == ENV['CONTRACT_ADDRESS'].downcase
      "Messages Smart Contract"
    elsif account.hash_address.downcase == Account.user_pool.try(:hash_address).try(:downcase)
      "User Growth Pool"
    elsif account.user
      link_to "@#{account.user.username}", user_path(account.user.username)
    else
      short_address(account.hash_address, length: 15)
    end
  end

  def short_address(address, length: 10)
    half = length / 2
    total = address.size
    beginning = address[0..half]
    ending = address[total-half..total]
    "#{beginning}..#{ending}"
  end

  def current_account_avatar(size: :medium)
    account_avatar(current_account, size: size)
  end

  def account_avatar(account, size: :medium)
    if account.avatar_ipfs_hash.present?
      ipfs_image_url(account.avatar_ipfs_hash, size: size)
    else
      default_avatar(size: size)
    end
  end

  def ipfs_image_url(ipfs_hash, size: :medium)
    "http://ipfs.numachain.com/image/#{ipfs_hash}?size=#{avatar_sizes[size]}"
  end

  def default_avatar(size: :medium)
    "/avatar/Avatar@#{size}.png"
  end

  def avatar_sizes
    {
      medium: 400,
      large: 800,
      thumb: 200
    }
  end
end
