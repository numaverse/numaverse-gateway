class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def create
    @favorite = current_account.favorites.create(message_id: params[:message_id])
    @favorite.batch!

    render 'show'
  end

  def attach_transaction
    @favorite = Favorite.find(params[:id])
    attach_transaction_to(@favorite)
  end
end
