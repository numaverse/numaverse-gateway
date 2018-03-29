module ActivityStreamable
  extend ActiveSupport::Concern

  included do
    include AASM
    include Uuidable

    has_one :tx, class_name: 'Transaction', as: :transactable
    has_many :batch_items, as: :batchable

    scope :visible, -> { where('hidden_at is null') }

    aasm do
      state :draft, initial: true
      state :uploaded, :pending, :confirmed, :batched

      event :upload do
        transitions from: [:draft, :uploaded, :pending, :confirmed], to: :uploaded
      end

      event :batch, after: [:update_federated_model, :add_to_batch] do
        transitions from: [:draft, :uploaded, :pending, :confirmed], to: :batched
      end

      event :transact, after: :update_federated_model do
        transitions from: [:draft, :uploaded, :pending, :confirmed], to: :pending
      end

      event :confirm do
        transitions from: [:draft, :uploaded, :pending, :confirmed, :batched], to: :confirmed
      end
    end
  end

  def ipfs_json
    activity_stream.data
  end

  def ipfs_object_data
    activity_stream.object_data
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

  def add_to_batch
    batch_item = sender_account.fetch_batch.batch_items.find_or_create_by(
      batchable: self,
      aasm_state: 'batched'
    )
    batch_item.update(batched_at: DateTime.now)
  end

  def batches
    Batch.joins(:batch_items).where('batch_items.batchable_type = ? AND batch_items.batchable_id = ?', self.class, id)
  end

  def update_federated_model
    # skip, implement in base level class
  end
end
