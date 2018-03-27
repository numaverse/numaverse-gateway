module HashAddressable
  extend ActiveSupport::Concern

  class_methods do
    def by_address(address)
      find_by address: address.downcase.gsub(/^0x/, '')
    end

    def make_by_address(address)
      return nil if address.blank? || address.from_hex == 0
      account = by_address(address)
      return account if account.is_a?(Account)
      create(address: address)
    end
  end

  included do
    validates_uniqueness_of :address
    validates_presence_of :address
    validate :has_no_0x
    before_validation :strip_0x
  end

  def has_no_0x
    if address.present? && address.starts_with?('0x')
      self.errors.add(:address, "Address cannot contain 0x.")
    end
    true
  end

  def strip_0x
    if address.present?
      self.address = address.downcase.gsub /^0x/, ''
    end
  end

  def hash_address
    '0x'+address
  end

end