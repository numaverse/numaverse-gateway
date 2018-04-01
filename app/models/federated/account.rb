class Federated::Account < ApplicationRecord
  belongs_to :local_account, foreign_key: 'local_account_id', class_name: 'Account', optional: true
  has_many :from_follows, foreign_key: 'from_account_id', class_name: "Federated::Follow"
  has_many :to_follows, foreign_key: 'to_account_id', class_name: "Federated::Follow"
  has_many :messages, foreign_key: 'federated_account_id', class_name: 'Federated::Message'

  before_create :generate_keypair, if: :local?

  scope :remote, -> { where.not(federated_id: nil) }

  class << self
    def from_remote_id(id)
      account = Federated::Account.find_or_initialize_by(federated_id: id)
      if account.new_record?
        account.fetch!
      end
      account
    end

    def shared_inboxes
      Federated::Account.remote.where.not(shared_inbox_url: nil).select('distinct(shared_inbox_url)').pluck('shared_inbox_url')
    end
  end

  def local?
    local_account_id.present?
  end

  def remote?
    federated_id.present?
  end

  def key
    @key ||= OpenSSL::PKey::RSA.new(private_key || public_key)
  end

  def fetch!
    return true unless remote?
    json = ActivityPub::Request.new(federated_id).perform_json
    data = json.except('@context')
    update(
      public_key: json['publicKey'].try(:[], 'publicKeyPem'),
      object_data: data,
      username: json['preferredUsername'],
      display_name: json['name'],
      avatar_url: json['icon'].try(:[], 'url'),
      inbox_url: json['inbox'],
      outbox_url: json['outbox'],
      followers_url: json['followers'],
      following_url: json['following'],
      shared_inbox_url: json['endpoints'].try(:[], 'sharedInbox'),
    )
  end

  def follower_ids
    @follower_ids ||= to_follows.select('distinct(from_account_id)').uniq.pluck('from_account_id')
  end

  def follower_inboxes
    without_shared_inbox = Federated::Account.remote.where(shared_inbox_url: nil, id: follower_ids).select('distinct(inbox_url)').pluck('inbox_url')
    without_shared_inbox + self.class.shared_inboxes
  end

  def inbox
    object_data['inbox']
  end

  # hack because sometimes class names clash :( i suck i know
  def local_account
    "Account".constantize.find(local_account_id)
  end

  def url_id
    if remote?
      federated_id
    else
      Rails.application.routes.url_helpers.ap_account_url(local_account.hash_address)
    end
  end

  private

  def generate_keypair
    pair = OpenSSL::PKey::RSA.new(2048)
    self.private_key = pair.to_pem
    self.public_key = pair.public_key.to_pem
  end
end
