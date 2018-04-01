class ActivityPub::DeliveryJob < ApplicationJob
  queue_as :default

  def perform(object)
    if object.is_a?(Federated::Version)
      deliver_version(object)
    elsif object.is_a?(Federated::Follow)
      deliver_follow(object)
    end
  end

  def deliver_follow(follow)
    account = follow.from_account
    return true unless account.local?
    to_account = follow.to_account
    return true unless to_account.inbox_url.present? && to_account.remote?

    json = ActivityPub::Follow.new(follow).data
    inbox = to_account.inbox_url

    Rails.logger.debug("Sending follow to #{to_account.url_id}")
    request = ActivityPub::Request.new(inbox,
      from_account: account,
      verb: :post,
      body: json.to_json
    )
    handle_response(request)
  end

  def deliver_version(version)
    account = version.federated_message.federated_account
    
    return true unless account.local?

    renderer = ApplicationController.new
    json = renderer.render_to_string('activity_pub/version.json.jbuilder', locals: { 
      version: version, 
      account: account.local_account,
    })

    inboxes = account.follower_inboxes

    inboxes.each do |inbox|
      Rails.logger.debug "Delivering to inbox: #{inbox}"
      
      request = ActivityPub::Request.new(inbox, 
        from_account: account, 
        verb: :post, 
        body: json,
      )
      handle_response(request)
    end
  end

  def handle_response(request)
    request.perform
    if !request.success?
      raise "Error when delivering request to inbox. Code: #{request.response.code} Body: #{request.response.body}"
    end
  end
end
