class MessagesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  skip_before_action :verify_authenticity_token, only: [:create, :update, :repost, :reply, :destroy, :attach_transaction]
  before_action :set_message, only: [:show, :edit, :update, :destroy, :refresh, :repost, :reply, :attach_transaction]

  def new
  end

  def create
    @message = current_account.messages.create(message_params)
    @message.post_on_ipfs
  end

  def attach_transaction
    authorize! :manage, @message
    attach_transaction_to(@message)
  end

  def show
  end

  def edit
    authorize! :update, @message
  end

  def update
    authorize! :update, @message
    if @message.article? || @message.micro?
      @message.assign_attributes(message_params)
    end
    @message.post_on_ipfs

    @message.save!

    render 'create'
  end

  def refresh
    authorize! :refresh, @message
    @message.update_tx_data
    redirect_to @message
  end

  def destroy
    authorize! :destroy, @message
    @message.hidden_at ||= DateTime.now
    @message.post_on_ipfs

    render 'create'
  end
  
  def repost
    @repost = @message.reposts.create(
      account: current_account,
      body: @message.body,
      json_schema: :micro
    )
    @repost.post_on_ipfs

    @message = @repost
    render 'create'
  end

  def reply
    @reply = @message.replies.create(
      account: current_account,
      body: params[:body],
      json_schema: :micro,
    )

    @reply.post_on_ipfs

    @message = @reply
    render 'create'
  end

  private

  def message_params
    params.permit(:body, :title, :tldr, :json_schema, tag_names: [])
  end

  def set_message
    @message = Message.unscoped.find(params[:id])
  end
end
