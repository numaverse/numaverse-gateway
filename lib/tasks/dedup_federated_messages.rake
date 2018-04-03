namespace :federated do
  task dedup_messages: :environment do
    Federated::Message.remote.all.to_a.each do |message|
      begin
        message.reload
        fed_id = message.object_data.try(:[],'id')
        next if fed_id.blank?
        others = Federated::Message.where.not(id: message.id).where("object_data ->> 'id' = ?", fed_id)
        others.destroy_all
      rescue ActiveRecord::RecordNotFound => e
      end
    end
  end
end