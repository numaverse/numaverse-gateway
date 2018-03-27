class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:upload_avatar]
  before_action :authenticate_user!, only: [:new_message, :faucet_captcha]
  helper_method :can_skip_captcha?, :faucet_min, :faucet_max

  def home
    @messages = Message.order('created_at desc')
      .visible
      .page(params[:page])
      .where('json_schema in (1,2)')
    if current_account && request.path == "/"
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

  def can_skip_captcha?
    Rails.env.development? && params['dev_recaptcha'].blank?
  end

  def faucet_min
    1e18.to_i / 10
  end

  def faucet_max
    1e18.to_i
  end
end
