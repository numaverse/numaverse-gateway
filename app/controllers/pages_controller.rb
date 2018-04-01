class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:new_message]

  def home
    query = params[:query]
    # check if its a webfinger search
    if query && /\A@[a-z0-9][a-z0-9_]*@[a-z0-9]*([\.\w]*|[:0-9]*)\z/.match?(query)
      redirect_to search_federated_accounts_path(handle: query)
      return
    end
    @messages = Message.order('created_at desc')
      .visible
      .page(params[:page])
    if current_account && request.path == "/" && has_follows
      @messages = current_account.following_messages(relation: @messages)
    end
    if params[:query]
      @messages = @messages.advanced_search(body: params[:query])
    end
  end

  def new_message
    @message = Message.new
  end

  def upload_avatar
    if params[:file].size > 2.megabytes
      size = helpers.number_to_human_size(params[:file].size)
      message = "Sorry, profile pictures must be less than 2 MB. The file you uploaded was #{size}."
      render json: { message: message }, status: 422
    else
      ipfs_hash = IpfsServer.add(params[:file].tempfile).hashcode
      render json: { ipfs_hash: ipfs_hash, gateway_url: helpers.ipfs_image_url(ipfs_hash) }
    end
  end
  
  def welcome
  end

  private

  def has_follows
    current_account&.following_account_ids != [current_account.id]
  end
end
