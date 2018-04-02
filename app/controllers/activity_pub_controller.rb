class ActivityPubController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:inbox_incoming_message]
  before_action :set_content_type
  before_action :set_account, only: [:outbox, :account, :inbox, :inbox_incoming_message, :followers, :following]

  def outbox
    @versions = @account.federated_message_versions.most_recent.page(params[:page])
    # ap @versions.first
    
    render template: 'activity_pub/outbox.json.jbuilder'
  end

  def webfinger
    username = params[:resource].split('@').first.split(':').last
    @account = Account.find_by!(username: username)
    render template: 'activity_pub/webfinger.json.jbuilder', content_type: 'application/jrd+json'
  end

  def account
    render template: 'activity_pub/account.json.jbuilder'
  end

  def message
    @message = Federated::Message.find(params[:message_id])
    render template: 'activity_pub/message.json.jbuilder'
  end

  def activity
    @version = Federated::Version.find(params[:version_id])
    @account = Account.find(@version.federated_message.local_account_id)
    render template: 'activity_pub/version.json.jbuilder', locals: { version: @version, account: @account }
  end

  def inbox_incoming_message
    if @signed_account = ActivityPub::Signature.verify_request(request)
      ActivityPub::InboxFactoryJob.perform_later(@signed_account, @account.federated_account, request.raw_post.force_encoding('UTF-8'))
      head 200
    else
      render plain: "Invalid signature", status: 401
    end
  end

  def followers
    @follows = Federated::Follow.where(to_account: @account.federated_account).page(params[:page])
    render template: 'activity_pub/followers.json.jbuilder'
  end

  def following
    @follows = Federated::Follow.where(from_account: @account.federated_account).page(params[:page])
    render template: 'activity_pub/following.json.jbuilder'
  end

  private

  def set_content_type
    self.content_type = 'application/activity+json'
  end

  def set_account
    @account ||= Account.by_address(params[:account_id])
    raise ActiveRecord::RecordNotFound unless @account.present?
  end
end
