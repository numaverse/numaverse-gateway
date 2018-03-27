class ActivityPub::DeliveryJob < ApplicationJob
  queue_as :default

  def perform(version)
    account = version.federated_message.federated_account
    account.to_follows.each do |follow|
      deliver_to_account = follow.from_account
      deliver_from_account = follow.to_account
      next unless deliver_to_account.remote? && deliver_from_account.local?
      inbox = deliver_to_account.object_data['inbox']
      renderer = ApplicationController.new
      json = renderer.render_to_string('activity_pub/_version.json.jbuilder', locals: { 
        version: version, 
        account: deliver_from_account.local_account 
      })
      request = ActivityPub::Request.new(inbox, 
        from_account: deliver_from_account, 
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
