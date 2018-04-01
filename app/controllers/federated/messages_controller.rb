class Federated::MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    federated_account = current_account.update_federated_model
    @from_follow_ids = federated_account.from_follows.select('distinct(to_account_id)').pluck('to_account_id')
    @messages = Federated::Message.remote.visible
      .order('created_at desc')
      .where(federated_account_id: @from_follow_ids)
      .page(params[:page])
    # if params[:query]
    #   @messages = @messages.advanced_search(params[:query])
    # end
  end
end
