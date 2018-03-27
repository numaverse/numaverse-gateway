class FavoritesController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create
    @favorite = current_account.favorites.create(message_id: params[:message_id])
    @favorite.post_on_ipfs

    render 'show'
  end

  def attach_transaction
    @favorite = Favorite.find(params[:id])
    attach_transaction_to(@favorite)
  end
end
