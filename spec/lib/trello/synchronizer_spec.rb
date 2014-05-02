require 'spec_helper'

module Union::Trello
  describe Synchronizer do
    describe '.sync!' do
      let(:board) { create :board, new_list_id: 'NEW_LIST_ID', wip_list_id: 'WIP_LIST_ID', done_list_id: 'DONE_LIST_ID' }
      let(:mock_trello_card) { { 'id' => 'TRELLO_CARD_ID' } }

      before do
        TRELLO_API.stub(:list_cards).and_return([mock_trello_card, mock_trello_card], [mock_trello_card], [mock_trello_card, mock_trello_card])
        described_class.stub :create_or_update
      end

      it 'lists cards from new, wip, and done lists' do
        TRELLO_API.should_receive(:list_cards).with('NEW_LIST_ID')
        TRELLO_API.should_receive(:list_cards).with('WIP_LIST_ID')
        TRELLO_API.should_receive(:list_cards).with('DONE_LIST_ID')
        described_class.sync!(board.id)
      end

      it 'calls the create_or_update method for each trello card in list' do
        described_class.should_receive(:create_or_update).with(mock_trello_card, board).exactly(5).times
        described_class.sync!(board.id)
      end
    end

    describe '.create_or_update' do
      let(:board) { create :board }

      let(:trello_card) {
        {
          'id' => 'TRELLO_CARD_ID',
          'idList' => 'NEW_LIST_ID',
          'closed' => false,
          'dateLastActivity' => '2014-01-01T10:10:00.000Z',
          'due' => nil,
          'members' => [],
          'name' => 'UPDATED_TRELLO_CARD_NAME dummy-project-name',
          'desc' => 'TRELLO_CARD_DESCRIPTION dummy-server-name',
          'labels' => [{ 'color' => 'red', 'name' => 'Unplanned' }],
          'actions' => [
            {
              'data' => {
                'card' => {
                  'shortLink' => 'HqFPX1zS',
                  'name' => 'TRELLO_CARD_NAME'
                }
              },
              'memberCreator' => {
                'id' => '4e82e345cf2982000086f543',
                'fullName' => 'User Name',
                'username' => 'username'
              }
            }
          ]
        }
      }

      before do
        Project.any_instance.stub :refresh

        @dp = create :project, project_name: 'dummy-project-name'
        @ds = create :server, hostname: 'dummy-server-name'

        cached_tags = {
          'dummy-project-name' => { project_id: @dp.id },
          'dummy-server-name' => { server_id: @ds.id }
        }.with_indifferent_access

        Union::Trello::CachedCardTags.stub tags: cached_tags
      end

      context 'when the card exists' do
        let!(:card) { create :card, board: board, created_at: 1.day.ago, updated_at: 1.day.ago, data: { name: 'old name' }.with_indifferent_access }

        it 'updates card' do
          trello_card['id'] = card.trello_id
          described_class.create_or_update trello_card, board
          card.reload
          expect(card.data[:card][:name]).to eq('UPDATED_TRELLO_CARD_NAME dummy-project-name')
          expect(card.updated_at).to eq Time.parse('2014-01-01 10:10 +0000')
        end
      end

      context 'when the card does not exist' do
        it 'creates card' do
          described_class.create_or_update trello_card, board
          expect(Card.last.trello_id).to eq 'TRELLO_CARD_ID'
        end
      end

      it 'sets basic card details' do
        trello_card['closed'] = true
        trello_card['due'] = 2.days.from_now.strftime('%FT%T%:z')
        trello_card['members'] = [
          {
            'id' => '4e82e345cf2982000086f543',
            'fullName' => 'Some Name',
            'username' => 'somename1'
          },
          {
            'id' => '2982000086f5434e82e345cf',
            'fullName' => 'Another Name',
            'username' => 'anothername'
          }
        ]

        described_class.create_or_update trello_card, board

        last_card = Card.last
        expect(last_card.board).to eq board
        expect(last_card.trello_list_id).to eq('NEW_LIST_ID')
        expect(last_card.archived).to eq(true)
        expect(last_card.due).to be_within(2).of(2.days.from_now)
        expect(last_card.label).to eq 'red'
        expect(last_card.data).to eq({ card: { shortLink: 'HqFPX1zS', name: 'UPDATED_TRELLO_CARD_NAME dummy-project-name' }, 'members' => { '4e82e345cf2982000086f543' => { 'fullName' => 'Some Name', 'username' => 'somename1' }, '2982000086f5434e82e345cf' => { 'fullName' => 'Another Name', 'username' => 'anothername' } }, 'creator' => { 'id' => '4e82e345cf2982000086f543', 'fullName' => 'User Name', 'username' => 'username' } }.with_indifferent_access)
      end

      it 'scans and adds tags on the name and description' do
        described_class.create_or_update trello_card, board

        last_card = Card.last
        expect(last_card.projects.count).to eq 1
        expect(last_card.projects.first).to eq @dp
        expect(last_card.servers.count).to eq 1
        expect(last_card.servers.first).to eq @ds
      end

      it 'sets updated_at of card to date of last activity' do
        described_class.create_or_update trello_card, board

        expect(Card.last.updated_at).to eq Time.parse('2014-01-01 10:10 +0000')
      end
    end
  end
end
