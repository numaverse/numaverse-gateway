class BatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_batch, only: [:upload, :attach_transaction, :cancel]

  def show
    @batch = current_account.fetch_batch
    render template: 'batches/show.json.jbuilder'
  end

  def upload
    @batch.post_on_ipfs
    render json: { ipfs_hash: @batch.ipfs_hash, id: @batch.id }
  end

  def attach_transaction
    attach_transaction_to(@batch)
  end

  def cancel
    @batch.cancel!
    render json: { success: true }
  end

  private

  def set_batch
    @batch = Batch.find(params[:id])
  end
end
