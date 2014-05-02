require 'spec_helper'

module Union::Trello::WebhookActions
  # Let's test out some of the common features implemented in the base class of webhook action processors. We'll do this
  # by instantiating specific classes, but expecting features implemented in the base class.
  describe Base do
    include WebhookRequestHelpers

    let(:request) { load_request(:create_card) }
    let(:request_object) { JSON.parse(request).with_indifferent_access }

    before :each do
      Project.any_instance.stub :refresh
      @project = create :project, project_name: 'super-project'
      @server = create :server, hostname: 'infrastructure-test-server'
      @board = create :board, trello_board_id: '52a82b69836ea6ce2f04c390'
      Union::Trello::CachedCardTags.stub tags: { 'super-project' => { project_id: @project.id }, 'infrastructure-test-server' => { server_id: @server.id } }
    end

    context 'when an action is received for a non-existent card' do
      subject { CreateCard.new request_object }

      it 'creates an entry for the card with basic details' do
        subject.process
        saved_card = Card.first
        expect(saved_card.trello_id).to eq '52b181af1d1afd88520108bd'
        expect(saved_card.trello_list_id).to eq '52a82b69836ea6ce2f04c391'
        expect(saved_card.data).to eq({ card: { shortLink: 'Gzt3a3cc', idShort: 10, name: 'deploy super-project to infrastructure-test-server', id: '52b181af1d1afd88520108bd' }, creator: { id: '52a82b060ab45b5130021afd', avatarHash: '439e7a9de37777e92eb51e3287a2aa4e', fullName: 'Super Coder', initials: 'SC', username: 'supercoder1' } }.with_indifferent_access)
        expect(saved_card.projects.first).to eq(@project)
        expect(saved_card.servers.first).to eq(@server)
        expect(saved_card.board).to eq @board
      end

      context 'when the action did not include information about which list the card is on' do
        let(:request) { load_request(:update_card_add_due_date) }
        let(:trello_card) { { 'idList' => 'MOCKED_LIST_ID' } }

        subject { UpdateCard.new request_object }

        before :each do
          TRELLO_API.stub card: trello_card
        end

        it 'contacts the Trello API to set trello_list_id' do
          subject.process
          expect(Card.first.trello_list_id).to eq 'MOCKED_LIST_ID'
        end
      end
    end
  end
end
