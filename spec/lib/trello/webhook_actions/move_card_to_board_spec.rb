require 'spec_helper'

module Union::Trello::WebhookActions
  describe MoveCardToBoard do
    include WebhookRequestHelpers

    let(:move_card_to_board_request) { load_request(:move_card_to_board) }
    let(:move_card_to_board_object) { JSON.parse(move_card_to_board_request).with_indifferent_access }

    subject { described_class.new move_card_to_board_object }

    describe '#process' do
      let!(:board) { create :board, trello_board_id: '52e8ecd4efd3a17776f9114b' }
      let!(:card) { create :card, trello_id: '52b4294feb2745b76701e9f5' }

      it 'updates the board ID of card' do
        subject.process
        card.reload
        card.board.should == board
      end

      it 'updates the trello_list_id of the card' do
        subject.process
        card.reload
        card.trello_list_id.should == '52e8ecd4efd3a17776f9114d'
      end
    end
  end
end
