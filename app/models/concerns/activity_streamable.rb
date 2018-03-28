module ActivityStreamable
  extend ActiveSupport::Concern

  included do
    include AASM

    has_one :tx, class_name: 'Transaction', as: :transactable

    scope :visible, -> { where('hidden_at is null') }

    aasm do
      state :draft, initial: true
      state :uploaded, :pending, :confirmed

      event :upload do
        transitions from: [:draft, :uploaded, :pending, :confirmed], to: :uploaded
      end

      event :transact, after: :update_federated_model do
        transitions from: [:draft, :uploaded, :pending, :confirmed], to: :pending
      end

      event :confirm do
        transitions from: [:draft, :uploaded, :pending, :confirmed], to: :confirmed
      end
    end
  end

  def ipfs_json
    activity_stream.data
  end

  def post_on_ipfs(save: true)
    file = Tempfile.new("Numa#{self.class}")
    file.write(ipfs_json.to_json)
    file.rewind

    link = IpfsServer.add(file)

    file.close
    file.unlink

    if link.hashcode.blank?
      raise "No hashcode was returned from the IPFS server. Unable to upload to IPFS."
    end

    self.ipfs_hash = link.hashcode
    self.upload
    self.save! if save

    link
  end

  def smart_contract_args
    hash_function, hash_size, hex = IpfsServer.hash_data(ipfs_hash)
    [
      '0x'+hex
    ]
  end

  def update_federated_model
    # skip, implement in base level class
  end
end
