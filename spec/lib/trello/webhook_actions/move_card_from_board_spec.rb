require 'spec_helper'

module Union::Trello::WebhookActions
  describe MoveCardFromBoard do
    include WebhookRequestHelpers

    let(:move_card_from_board_request) { load_request(:move_card_from_board) }
    let(:move_card_from_board_object) { JSON.parse(move_card_from_board_request).with_indifferent_access }

    subject { described_class.new move_card_from_board_object }

    describe '#process' do
      let!(:card) { create :card, trello_id: '52b4294feb2745b76701e9f5' }

      context 'when the target board exists' do
        let!(:target_board) { create :board, trello_board_id: '52e8ecd4efd3a17776f9114b' }

        it 'sets the board ID to that of the new board' do
          subject.process
          expect(Card.last.board_id).to eq target_board.id
        end
      end

      context 'when the target board does not exist' do
        it 'creates the board and update board ID on card' do
          subject.process

          card.reload
          expect(card.board.trello_board_id).to eq '52e8ecd4efd3a17776f9114b'
        end
      end
    end
  end
end
