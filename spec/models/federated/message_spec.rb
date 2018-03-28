require 'rails_helper'

RSpec.describe Federated::Message, type: :model do
  describe 'versions' do
    it 'creates a created version' do
      message = create(:federated_message, object_data: { content: 'hello', summary: '132' })
      expect(message.versions.size).to eql(1)
      version = message.versions.first
      expect(version.object_changes).to eql(message.object_data)
      expect(version.created?).to eql(true)
      expect(version.local_message_id).to eql(message.local_message_id)
    end

    it 'tracks updates' do
      message = create(:federated_message, object_data: { content: 'hello', summary: '132' })
      expect(message.versions.size).to eql(1)

      message.update(object_data: message.object_data.merge(content: 'updated'))
      expect(message.versions.size).to eql(2)
      version = message.versions.last

      expect(version.object_changes).to hash_eql({content: 'updated'})
      expect(version.updated?).to eql(true)
      expect(version.local_message_id).to eql(message.local_message_id)

      message.update(object_data: message.object_data.merge(summary: 'another', new_key: 9000))
      expect(message.versions.size).to eql(3)
      version = message.versions.last

      expect(version.object_changes).to hash_eql({summary: 'another', new_key: 9000})
    end

    it 'works end-to-end with local message changes' do
      message = create(:message)
      message.transact

      fed_message = message.reload.federated_message
      expect(fed_message.versions.first.created?).to eql(true)

      message.update(body: 'wasup')
      message.transact
      expect(fed_message.versions.reload.last.object_changes).to hash_eql({content: 'wasup', plainTextContent: 'wasup'})
    end
  end
end
