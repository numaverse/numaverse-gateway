require 'rails_helper'

RSpec.describe Favorite, type: :model do
  it 'sends a notification' do
    delivery = double
    expect(delivery).to receive(:deliver_later).with(no_args)
    expect(NotificationMailer).to receive(:favorite).with(instance_of(Favorite)).and_return(delivery)
    create(:favorite, account: create(:account_with_data))
  end
end
