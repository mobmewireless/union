require 'spec_helper'

module Union::Trello
  describe Tasks do
    describe '.archive_done_cards' do
      let(:board_1) { create :board, trello_webhook_id: 'WEBHOOK_1' }
      let(:board_2) { create :board, trello_webhook_id: 'WEBHOOK_2' }
      let(:unsubscribed_board) { create :board }

      let(:trello_done_card_1) {
        {
          'id' => 'CARD_ID_0',
          'actions' => [
            {
              'date' => 7.5.days.ago.strftime('%FT%T%:z')
            }
          ]
        }
      }

      let(:trello_done_card_2) {
        {
          'id' => 'CARD_ID_1',
          'actions' => [
            {
              'date' => 9.days.ago.strftime('%FT%T%:z')
            }
          ]
        }
      }

      let(:trello_done_card_3) {
        {
          'id' => 'CARD_ID_2',
          'actions' => [
            {
              'date' => 11.days.ago.strftime('%FT%T%:z')
            }
          ]
        }
      }

      let(:trello_done_card_4) {
        {
          'id' => 'CARD_ID_3',
          'actions' => [
            {
              'date' => 6.days.ago.strftime('%FT%T%:z')
            }
          ]
        }
      }

      before do
        TRELLO_API.stub :archive
        TRELLO_API.stub(:done_cards).with(board_1) { [trello_done_card_1, trello_done_card_2] }
        TRELLO_API.stub(:done_cards).with(board_2) { [trello_done_card_3, trello_done_card_4] }
      end

      it 'retrieves done cards for all subscribed boards' do
        TRELLO_API.should_receive(:done_cards).with(board_1)
        TRELLO_API.should_receive(:done_cards).with(board_2)
        described_class.archive_done_cards
      end

      it 'calls the Trello API to archive inactive done cards' do
        TRELLO_API.should_receive(:archive).with('CARD_ID_0')
        TRELLO_API.should_receive(:archive).with('CARD_ID_1')
        TRELLO_API.should_receive(:archive).with('CARD_ID_2')
        described_class.archive_done_cards
      end

      context 'if a card has empty actions' do
        let(:trello_done_card_3) {
          {
            'id' => 'CARD_ID_2',
            'actions' => [],
            'dateLastActivity' => 11.days.ago.strftime('%FT%T%:z')
          }
        }

        it "'uses card's dateLastActivity field to check whether it should be archived" do
          TRELLO_API.should_receive(:archive).with('CARD_ID_2')
          described_class.archive_done_cards
        end
      end
    end
  end
end
