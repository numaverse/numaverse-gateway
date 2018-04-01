require 'rails_helper'

RSpec.describe BatchesController, type: :controller do
  let(:account) { create(:account) }

  context 'logged in' do
    let(:follow) { create(:follow, from_account: account) }
    let(:message) { create(:message, account: account) }
    let(:batch) { account.fetch_batch }

    before do
      sign_in_account(account)
      follow.batch
      message.batch
    end
    
    describe "GET #show" do

      before do
        get :show, format: :json
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it 'fetches a batch' do
        expect(assigns(:batch)).to eql(batch)
      end

      context 'render_views' do
        render_views
        let(:json) { JSON.parse(response.body) }

        it 'returns json with a count of items' do
          expect(json['count']).to eql(2)
        end

        it 'doesnt include confirmed count' do
          batch = account.fetch_batch
          batch.confirm
          get :show
          expect(json['count']).to eql(0)
        end

        it 'works with a new batch' do
          batch = account.fetch_batch
          batch.confirm
          favorite = create(:favorite, account: account)
          favorite.batch
          get :show
          expect(json['count']).to eql(1)
        end

        it 'includes basic batch item info' do
          expect(json['items'].size).to eql(2)
          expect(json['items'].find {|i| i['item_type'] == 'Follow'}).not_to be_blank
          expect(json['items'].find {|i| i['item_type'] == 'Message'}).not_to be_blank
        end
      end
    end

    describe '#upload' do
      before do
        post :upload, params: { id: batch.id }
      end

      it 'uploads the batch to ipfs' do
        expect(batch.reload.ipfs_hash).not_to be_blank
      end

      context 'render_views' do
        render_views
        let(:json) { JSON.parse(response.body) }

        it 'returns the ipfs hash' do
          expect(json['ipfs_hash']).to eql(batch.reload.ipfs_hash)
        end
      end
    end

    describe '#attach_transaction', :end_to_end do
      let(:account) { make_eth_account }
      it 'attaches a tx to the batch' do
        tx = post_batch_on_chain(batch)
        hash = tx.hash_address
        tx.destroy
        expect(batch.tx).to be_blank
        post :attach_transaction, params: { tx_hash: hash, id: batch.id }
        expect(batch.reload.tx).not_to be_blank
        expect(batch).to be_pending
        expect(batch.batch_items.batched.count).to eql(0)
        expect(batch.batch_items.pending.count).to eql(2)
      end
    end

    describe '#cancel' do
      before do
        batch.update(ipfs_hash: "a fake hash")
        batch.transact!
        post :cancel, params: { id: batch.id }
      end

      it 'moves the batch backed to batched state' do
        batch.reload
        expect(batch).to be_batched
        expect(batch.ipfs_hash).to be_blank
        expect(batch.batch_items.batched.count).to eql(2)
      end
      
    end
  end

end
