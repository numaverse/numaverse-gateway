class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    @follow = Follow.find_by(from_account_id: current_account.id, to_account_id: params[:to_account_id])
    if @follow.present?
      @follow.update(hidden_at: nil)
    else
      @follow = Follow.create!(
        from_account_id: current_account.id,
        to_account_id: params[:to_account_id]
      )
    end
    @follow.batch!

    render json: { id: @follow.id, ipfs_hash: @follow.ipfs_hash }
  end

  def attach_transaction
    @follow = Follow.find(params[:id])
    attach_transaction_to(@follow)
  end

  def show
    @follow = Follow.find_by(from_account_id: current_account.id, to_account_id: params[:id], hidden_at: nil)

    if @follow
      authorize! :read, @follow
      render json: { id: @follow.id }
    else
      render json: nil
    end
  end

  def destroy
    @follow = Follow.find(params[:id])
    authorize! :destroy, @follow
    @follow.update(hidden_at: DateTime.now)
    @follow.batch!
    render json: { id: @follow.id, ipfs_hash: @follow.ipfs_hash }
  end
end
