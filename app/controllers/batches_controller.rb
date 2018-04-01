class BatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_batch, only: [:upload, :attach_transaction, :cancel]

  def show
    @batch = current_account.fetch_batch
    render 'batches/show.json.jbuilder'
  end

  def upload
    authorize! :manage, @batch
    @batch.post_on_ipfs
    render json: { ipfs_hash: @batch.ipfs_hash, id: @batch.id }
  end

  def attach_transaction
    authorize! :manage, @batch
    attach_transaction_to(@batch)
  end

  def cancel
    authorize! :manage, @batch
    @batch.cancel!
    render json: { success: true }
  end

  private

  def set_batch
    @batch = Batch.find(params[:id])
  end
end
