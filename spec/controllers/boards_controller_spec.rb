require 'spec_helper'

describe BoardsController do
  include AuthenticationHelpers

  let!(:board) { create :board }

  before do
    login_as_admin!
  end

  describe "GET 'show'" do
    let(:board_lists) { [{ 'id' => 'TRELLO_LIST_1', 'name' => 'Trello List 1' }, { 'id' => 'TRELLO_LIST_2', 'name' => 'Trello List 2' }] }

    before do
      TRELLO_API.stub board_lists: board_lists
    end

    it 'assigns @board' do
      get :show, id: board.id
      expect(assigns(:board)).to eq board
    end

    it 'loads trello lists for board into @lists' do
      get :show, id: board.id
      expect(assigns(:lists)).to eq [['Trello List 1', 'TRELLO_LIST_1'], ['Trello List 2', 'TRELLO_LIST_2']]
    end
  end

  describe "PATCH 'update'" do
    let(:new_list_id) { Faker::Lorem.characters(20) }
    let(:wip_list_id) { Faker::Lorem.characters(20) }
    let(:done_list_id) { Faker::Lorem.characters(20) }

    it 'sets updates board record' do
      patch :update, { id: board.id, board: { new_list_id: new_list_id, wip_list_id: wip_list_id, done_list_id: done_list_id } }
      board.reload
      expect(board.new_list_id).to eq new_list_id
      expect(board.wip_list_id).to eq wip_list_id
      expect(board.done_list_id).to eq done_list_id
    end
  end

  describe "DELETE 'destroy'" do
    it 'calls destroy on chosen board' do
      expect {
        delete :destroy, id: board.id
      }.to change(Board, :count).by(-1)
    end

    it 'redirects to admin index' do
      delete :destroy, id: board.id
      response.should redirect_to admin_index_url
    end
  end

  describe "POST 'subscribe'" do
    let(:webhook_create_response) {
      {
        'id' => 'TRELLO_RETURNED_WEBHOOK_ID'
      }
    }

    before do
      TRELLO_API.stub webhook_subscribe: webhook_create_response
    end

    it 'creates webhook for board' do
      TRELLO_API.should_receive(:webhook_subscribe).with(board.trello_board_id)
      post :subscribe, id: board.id
    end

    it 'sets board webhook ID' do
      post :subscribe, id: board.id
      board.reload
      expect(board.trello_webhook_id).to eq 'TRELLO_RETURNED_WEBHOOK_ID'
    end

    it 'redirects to admin index' do
      post :subscribe, id: board.id
      response.should redirect_to admin_index_url
    end
  end

  describe "POST 'unsubscribe'" do
    let!(:board) { create :board, trello_webhook_id: 'TRELLO_WEBHOOK_ID' }

    before do
      TRELLO_API.stub :webhook_unsubscribe
    end

    it 'deletes existing webhook' do
      TRELLO_API.should_receive(:webhook_unsubscribe).with(board.trello_webhook_id)
      post :unsubscribe, id: board.id
    end

    it 'nullifies trello_webhook_id' do
      post :unsubscribe, id: board.id
      board.reload
      expect(board.trello_webhook_id).to be_nil
    end

    it 'redirects to admin index' do
      post :unsubscribe, id: board.id
      response.should redirect_to admin_index_url
    end
  end
end
