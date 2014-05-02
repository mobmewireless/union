require 'spec_helper'

module Union::Trello::WebhookActions
  describe UpdateCard do
    include WebhookRequestHelpers

    let(:update_card_request) { load_request(:update_card_move_list) }
    let(:update_card_object) { JSON.parse(update_card_request).with_indifferent_access }

    subject { described_class.new update_card_object }

    describe '#process' do
      context 'when action indicates move of card from one list to another' do
        let!(:card) { create :card, trello_id: '52b181af1d1afd88520108bd' }

        it 'stores new trello_list_id' do
          subject.process
          card.reload
          expect(card.trello_list_id).to eq '52a82b69836ea6ce2f04c392' # List ID from file.
        end

        context 'when action indicates it has moved to wip' do
          before do
            Card.any_instance.stub status: Card::STATUS_WIP
          end

          context 'when started_at is not set' do
            it 'sets started_at' do
              subject.process
              card.reload
              expect(card.started_at).to be_within(2).of(Time.now)
            end
          end

          context 'when started_at is set' do
            let!(:card) { create :card, trello_id: '52b181af1d1afd88520108bd', started_at: 1.hour.ago }

            it 'does not modify started_at' do
              subject.process
              card.reload
              expect(card.started_at).to_not be_within(2).of(Time.now)
            end
          end
        end

        context 'when action indicates it has moved to done' do
          before do
            Card.any_instance.stub status: Card::STATUS_DONE
          end

          context 'when completed_at is not set' do
            it 'sets completed_at' do
              subject.process
              card.reload
              expect(card.completed_at).to be_within(2).of(Time.now)
            end
          end

          context 'when completed_at is set' do
            let!(:card) { create :card, trello_id: '52b181af1d1afd88520108bd', completed_at: 1.hour.ago }

            it 'does not modify started_at' do
              subject.process
              card.reload
              expect(card.completed_at).to_not be_within(2).of(Time.now)
            end
          end
        end
      end

      context 'when action indicates addition of due date' do
        let(:update_card_request) { load_request(:update_card_add_due_date) }
        let!(:card) { create :card, trello_id: '52aae1c01d10b8f812007d10' }

        it 'sets due date on card' do
          subject.process
          card.reload
          expect(card.due).to eq Time.parse('2013-12-26T08:00:00.000Z')
        end
      end

      context 'when action indicates removal of due date' do
        let(:update_card_request) { load_request(:update_card_remove_due_date) }
        let!(:card) { create :card, trello_id: '52aae1c01d10b8f812007d10', due: Time.now }

        it 'removes due date from card' do
          subject.process
          card.reload
          expect(card.due).to eq nil
        end
      end

      context 'when action indicates archival of card' do
        let(:update_card_request) { load_request(:update_card_archive) }
        let!(:card) { create :card, trello_id: '52a82b70a24220272104b9f2' }

        it 'sets archived to true' do
          subject.process
          card.reload
          expect(card.archived).to eq true
        end
      end

      context 'when action indicates removal of card from archive' do
        let(:update_card_request) { load_request(:update_card_unarchive) }
        let!(:card) { create :card, trello_id: '52aab57a2f61b35c650055ee' }

        it 'sets archived to true' do
          subject.process
          card.reload
          expect(card.archived).to eq false
        end
      end

      context 'when action indicates modification of card description' do
        let(:update_card_request) { load_request(:update_card_modify_description) }
        let!(:card) { create :card, trello_id: '52cfad1fa961d42d16fa28c7' }

        before do
          Project.any_instance.stub :refresh

          @sp = create :project, project_name: 'super-project'
          @sds = create :server, hostname: 'super-duper-server'
          @nsss = create :server, hostname: 'not-so-super-server'

          cached_tags = {
            'super-project' => { project_id: @sp.id },
            'super-duper-server' => { server_id: @sds.id },
            'not-so-super-server' => { server_id: @nsss.id }
          }.with_indifferent_access

          Union::Trello::CachedCardTags.stub tags: cached_tags
        end

        it 'adds tags to projects and servers' do
          subject.process
          card.reload
          expect(card.card_tags.count).to eq 3
          expect(card.projects.pluck :id).to eq [@sp.id]
          expect(card.servers.pluck(:id) - [@sds.id, @nsss.id]).to be_empty
        end
      end

      context 'when action indicates modification of card name' do
        let(:update_card_request) { load_request(:update_card_modify_name) }
        let!(:card) { create :card, trello_id: '52cfad1fa961d42d16fa28c7' }

        before do
          Project.any_instance.stub :refresh

          @sp = create :project, project_name: 'super-project'
          @nssp = create :project, project_name: 'not-so-super-project'
          @sds = create :server, hostname: 'super-duper-server'

          cached_tags = {
            'super-project' => { project_id: @sp.id },
            'not-so-super-project' => {project_id: @nssp.id},
            'super-duper-server' => { server_id: @sds.id }
          }.with_indifferent_access

          Union::Trello::CachedCardTags.stub tags: cached_tags
        end

        it 'adds tags to projects and servers' do
          subject.process
          card.reload
          expect(card.card_tags.count).to eq 3
          expect(card.projects.pluck :id).to eq [@sp.id, @nssp.id]
          expect(card.servers.pluck :id).to eq [@sds.id]
        end

        it 'updates the name of the card' do
          subject.process
          card.reload
          expect(card.data[:card][:name]).to eq 'deploy super-project and not-so-super-project to super-duper-server right away!'
        end
      end
    end
  end
end
