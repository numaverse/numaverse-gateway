class ActivityPub::DeliveryJob < ApplicationJob
  queue_as :default

  def perform(version)
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
      request.perform
      if !request.success?
        raise "Error when delivering request to inbox. Code: #{request.response.code} Body: #{request.response.body}"
      end
    end
  end
end
