class MessagesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_message, only: [:show, :edit, :update, :destroy, :repost, :reply, :attach_transaction]

  def new
  end

  def index
    @messages = Message.order('created_at desc')
      .visible
      .page(params[:page])
    if current_account && params[:all].blank? && has_follows
      @messages = current_account.following_messages(relation: @messages)
    end
    if params[:query]
      @messages = @messages.advanced_search(body: params[:query])
    end
  end

  def create
    @message = current_account.messages.create(message_params)
    @message.batch!
  end

  def show
    @batches = @message.batches
  end

  def edit
    authorize! :update, @message
  end

  def update
    authorize! :update, @message
    if @message.article? || @message.micro?
      @message.assign_attributes(message_params)
    end
    @message.batch!

    @message.save!

    render 'create'
  end

  def destroy
    authorize! :destroy, @message
    @message.hidden_at ||= DateTime.now
    @message.batch!

    render 'create'
  end
  
  def repost
    @repost = @message.reposts.create(
      account: current_account,
      body: @message.body,
      json_schema: :micro
    )
    @repost.batch!

    @message = @repost
    render 'create'
  end

  def reply
    @reply = @message.replies.create(
      account: current_account,
      body: params[:body],
      json_schema: :micro,
    )

    @reply.batch!

    @message = @reply
    render 'create'
  end

  private

  def has_follows
    current_account&.following_account_ids != [current_account.id]
  end

  def message_params
    params.permit(:body, :title, :tldr, :json_schema, tag_names: [])
  end

  def set_message
    @message = Message.unscoped.find(params[:id])
  end
end
