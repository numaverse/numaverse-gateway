class Federated::FollowsController < ApplicationController
  before_action :authenticate_user!

  def create
    @account = Federated::Account.find(params[:to_account_id])
    @follow = Federated::Follow.find_or_create_by(
      from_account_id: current_account.federated_account.id,
      to_account_id: @account.id,
    )
    redirect_to federated_account_path(@account.id), notice: "You've followed this account."
  end

  def destroy
    @follow = Federated::Follow.find(params[:id])
    authorize! :destroy, @follow
    @follow.destroy

    redirect_to federated_account_path(@follow.to_account_id), notice: "You've unfollowed this account."
  end
end
