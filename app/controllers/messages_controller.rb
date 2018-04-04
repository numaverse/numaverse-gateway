class MessagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_message, only: [:show, :edit, :update, :destroy, :repost, :reply, :attach_transaction, :tip]

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

  def tip
    tx = Transaction.make_by_address(params[:tx_hash])
    # if (tx.from_account != current_account) || (tx.to_account != @message.account)
    #   render json: { error: 'Invalid Tip' }, status: :unprocessable_entity
    #   return
    # end
    from_message = nil
    if params[:body].present?
      from_message = current_account.messages.create(
        body: params[:body],
        json_schema: :micro,
      )
      from_message.batch!
    end
    tip = current_account.from_tips.build(
      to_account: @message.account,
      tx_id: tx.id,
      tx_hash: tx.hash_address,
      to_message: @message,
      message: from_message,
    )
    tip.batch
    tip.save!

    render json: { tx_url: transaction_path(tx) }
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
