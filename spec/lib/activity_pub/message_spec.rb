require 'rails_helper'

describe ActivityPub::Message do
  context 'messages' do
    let(:data) { stream.hashie_data }
    let(:urls) { Rails.application.routes.url_helpers }

    context 'articles' do
      let(:article) { create(:article, foreign_id: rand(100), ipfs_hash: 'Qm' + SecureRandom.hex(22) ) }
      let(:stream) { ActivityPub::Message.new(article) }

      it 'creates an Article object' do
        expect(data.type).to eql("Article")
        expect(data.name).to eql(article.title)
        expect(data.content).to eql(article.sanitized_body)
        expect(data.summary).to eql(article.tldr)
        expect(data.id).to eql(urls.message_url(article.id))
        expect(data.foreign_id).to eql(article.foreign_id)
        expect(data.ipfs_hash).to eql(article.ipfs_hash)
        expect(data.plainTextContent).to eql(article.body)
      end

      it 'sets an actor' do
        actor = stream.data[:actor]
        expect(actor).to eql(ActivityPub::Person.new(article.account).object_data)
      end
    end

    context 'micro' do
      let(:message) { create(:message, foreign_id: rand(100), ipfs_hash: 'Qm' + SecureRandom.hex(22) ) }
      let(:stream) { ActivityPub::Message.new(message) }

      it 'creates a Note' do
        expect(data.type).to eql("Note")
        expect(data.content).to eql(message.sanitized_body)
        expect(data.plainTextContent).to eql(message.body)
      end
    end
  end
end