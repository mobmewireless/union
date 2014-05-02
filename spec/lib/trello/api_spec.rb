require 'spec_helper'

module Union::Trello
  describe API do
    let(:developer_public_key) { 'DEV_PUB_KEY' }
    let(:member_token) { 'MEMBER_TOKEN' }
    let(:get_response) { double 'GET Response' }
    let(:put_response) { double 'PUT Response' }
    let(:delete_response) { double 'DELETE Response'}

    def credentials(extra=nil)
      c = { query: { key: developer_public_key, token: member_token } }
      c[:query].merge!(extra) if extra
      c
    end

    subject { API.new developer_public_key, member_token }

    before do
      described_class.stub get: get_response
      described_class.stub put: put_response
      described_class.stub delete: delete_response
    end

    describe '#credentials' do
      it 'returns hash of key and token' do
        expect(subject.credentials).to eq(key: developer_public_key, token: member_token)
      end
    end

    describe '#list_cards' do
      it 'lists cards on list with members, and actions createCard and convertToCardFromCheckItem' do
        described_class.should_receive(:get).with('/lists/LIST_ID/cards', credentials(members: 'true', actions: 'createCard,convertToCardFromCheckItem'))
        subject.list_cards 'LIST_ID'
      end

      it 'returns GET response' do
        expect(subject.list_cards('LIST_ID')).to eq get_response
      end
    end

    describe '#archive' do
      it 'archives card with specified ID' do
        described_class.should_receive(:put).with('/cards/CARD_ID/closed', credentials(value: 'true'))
        subject.archive 'CARD_ID'
      end

      it 'returns PUT response' do
        expect(subject.archive('CARD_ID')).to eq put_response
      end
    end

    describe '#card' do
      it 'returns details for card with specified ID' do
        described_class.should_receive(:get).with('/cards/CARD_ID', credentials)
        subject.card 'CARD_ID'
      end

      it 'returns GET response' do
        expect(subject.card('CARD_ID')).to eq get_response
      end
    end

    describe '#done_cards' do
      let(:board) { create :board, done_list_id: 'DONE_LIST_ID' }

      it 'lists done cards with action updateCard:idList' do
        described_class.should_receive(:get).with('/lists/DONE_LIST_ID/cards', credentials(actions: 'updateCard:idList'))
        subject.done_cards(board)
      end

      it 'returns GET response' do
        expect(subject.done_cards(board)).to eq get_response
      end
    end

    describe '#boards' do
      it 'lists all accessible boards' do
        described_class.should_receive(:get).with('/members/me/boards', credentials(filter: 'open'))
        subject.boards
      end

      it 'returns GET response' do
        expect(subject.boards).to eq get_response
      end
    end

    describe '#webhook_subscribe' do
      let(:webhook_callback_url) { 'http://webhook/callback/url' }

      before do
        APP_CONFIG[:trello][:webhook_callback_url] = webhook_callback_url
      end

      after do
        APP_CONFIG[:trello][:webhook_callback_url] = ENV['TRELLO_WEBHOOK_CALLBACK_URL']
      end

      it 'creates new webhook' do
        described_class.should_receive(:put).with('/webhooks', credentials(callbackURL: webhook_callback_url, idModel: 'TRELLO_BOARD_ID'))
        subject.webhook_subscribe 'TRELLO_BOARD_ID'
      end

      it 'returns POST response' do
        expect(subject.webhook_subscribe 'TRELLO_BOARD_ID').to eq put_response
      end
    end

    describe '#webhook_unsubscribe' do
      it 'deletes existing webhook' do
        described_class.should_receive(:delete).with('/webhooks/TRELLO_WEBHOOK_ID', credentials)
        subject.webhook_unsubscribe 'TRELLO_WEBHOOK_ID'
      end

      it 'returns DELETE response' do
        expect(subject.webhook_unsubscribe 'TRELLO_WEBHOOK_ID').to eq delete_response
      end
    end

    describe '#board_lists' do
      it 'retrieves lists on board' do
        described_class.should_receive(:get).with('/boards/TRELLO_BOARD_ID/lists', credentials)
        subject.board_lists 'TRELLO_BOARD_ID'
      end

      it 'returns GET response' do
        expect(subject.board_lists 'TRELLO_BOARD_ID').to eq get_response
      end
    end
  end
end
