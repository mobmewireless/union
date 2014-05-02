require 'spec_helper'

describe Board do
  describe '.refresh!' do
    let(:existing_board) { create :board, trello_board_id: 'TEST_BOARD_ID' }
    let(:new_board_short_url) { Faker::Internet.url }

    let(:retrieved_boards) {
      [
        {
          'id' => existing_board.trello_board_id,
          'name' => 'Updated Board Name',
          'shortUrl' => existing_board.short_url
        },
        {
          'id' => 'BRAND_NEW_TRELLO_BOARD',
          'name' => 'Brand New Trello Board',
          'shortUrl' => new_board_short_url
        }
      ]
    }

    before do
      TRELLO_API.stub boards: retrieved_boards
    end

    it 'retrieves all accessible trello boards' do
      TRELLO_API.should_receive(:boards)
      described_class.refresh!
    end

    it 'creates missing boards' do
      described_class.refresh!
      new_board = Board.find_by(trello_board_id: 'BRAND_NEW_TRELLO_BOARD')
      expect(new_board.name).to eq 'Brand New Trello Board'
      expect(new_board.short_url).to eq new_board_short_url
    end

    it 'updates existing boards' do
      described_class.refresh!
      existing_board.reload
      expect(existing_board.name).to eq 'Updated Board Name'
    end
  end

  describe '#cards_with_status' do
    let(:new_list_id) { Faker::Lorem.characters(20) }
    let(:wip_list_id) { Faker::Lorem.characters(20) }
    let(:done_list_id) { Faker::Lorem.characters(20) }

    subject { create :board, new_list_id: new_list_id, wip_list_id: wip_list_id, done_list_id: done_list_id }

    before do
      create :card, trello_list_id: new_list_id # card on another board
      2.times { create :card, board: subject, trello_list_id: new_list_id } # new cards
      create :card, board: subject, trello_list_id: new_list_id, archived: true # archived new card
      create :card, board: subject, trello_list_id: wip_list_id # wip card
      create :card, board: subject, trello_list_id: wip_list_id, deleted: true # deleted wip card
      3.times { create :card, board: subject, trello_list_id: done_list_id } # done cards
    end

    it 'returns scope for cards on board with required status' do
      new_and_wip_cards = subject.cards_with_status(Card::STATUS_NEW, Card::STATUS_WIP)
      done_cards = subject.cards_with_status(Card::STATUS_DONE)

      expect(new_and_wip_cards.count).to eq 5
      expect(done_cards.count).to eq 3
    end

    context 'when exclude_discarded option is set' do
      it 'returns scope for cards on board with required status that have not been archived or deleted' do
        new_and_wip_cards = subject.cards_with_status(Card::STATUS_NEW, Card::STATUS_WIP, exclude_discarded: true)
        expect(new_and_wip_cards.count).to eq 3
      end
    end

    context 'when unexpected required status is supplied' do
      it 'raises StandardError' do
        expect {
          subject.cards_with_status(:foobar)
        }.to raise_error(StandardError)
      end
    end
  end
end
