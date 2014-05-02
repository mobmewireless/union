require 'spec_helper'

describe Card do
  describe '#status' do
    let(:board) { create :board }
    let(:card) { create :card, board: board, trello_list_id: 'SUPPLIED_LIST_ID' }

    context 'when supplied list ID matches configured new list ID' do
      let(:board) { create :board, new_list_id: 'SUPPLIED_LIST_ID' }

      it 'returns STATUS_NEW' do
        expect(card.status).to eq(Card::STATUS_NEW)
      end
    end

    context 'when supplied list ID matches configured wip list ID' do
      let(:board) { create :board, wip_list_id: 'SUPPLIED_LIST_ID' }

      it 'returns STATUS_WIP' do
        expect(card.status).to eq(Card::STATUS_WIP)
      end
    end

    context 'when supplied list ID matches configured done list ID' do
      let(:board) { create :board, done_list_id: 'SUPPLIED_LIST_ID' }

      it 'returns STATUS_DONE' do
        expect(card.status).to eq(Card::STATUS_DONE)
      end
    end

    context 'when supplied list ID is unknown' do
      it 'returns STATUS_UNKNOWN' do
        expect(card.status).to eq(Card::STATUS_UNKNOWN)
      end
    end
  end

  describe '#scan_and_add_tags' do
    let(:card) { create :card }

    before do
      Project.any_instance.stub :refresh

      @sp = create :project, project_name: 'super-project'
      @nssp = create :project, project_name: 'not-so-super-project-123'
      @cpsn_p = create :project, project_name: 'common-project-server-name'
      @cpsn_s = create :server, hostname: 'common-project-server-name'
      @sds = create :server, hostname: 'super-duper-server'
      @nsss = create :server, hostname: 'not-so-super-server-123'

      cached_tags = {
        'super-project' => { project_id: @sp.id },
        'not-so-super-project-123' => { project_id: @nssp.id },
        'common-project-server-name' => { project_id: @cpsn_p.id, server_id: @cpsn_s.id },
        'super-duper-server' => { server_id: @sds.id },
        'not-so-super-server-123' => { server_id: @nsss.id }
      }.with_indifferent_access

      Union::Trello::CachedCardTags.stub tags: cached_tags
    end

    it 'creates entries in CardTags for card' do
      card.scan_and_add_tags('Deploy super-project to super-duper-server and not-so-super-server-123 super-fast!')
      card.reload
      expect(card.card_tags.count).to eq(3)
      expect(card.projects.pluck(:id)).to eq([@sp.id])
      expect(card.servers.pluck(:id) - [@sds.id, @nsss.id]).to be_empty
    end

    context 'when the text contains FQNs that map to both a server and project' do
      it 'tags both server and project' do
        card.scan_and_add_tags('not-so-super-project-123 and common-project-server-name are broken on common-project-server-name... say, what?!')
        card.reload
        expect(card.card_tags.count).to eq(3)
        expect(card.projects.pluck(:id)).to eq([@nssp.id, @cpsn_p.id])
        expect(card.servers.pluck(:id)).to eq([@cpsn_s.id])
      end
    end
  end

  describe '#cycle_time' do
    context 'when completed_at and started_at are set' do
      let(:card) { create :card, completed_at: Time.now, started_at: 1.hour.ago, created_at: 2.hours.ago }

      it 'returns the time taken to complete card since work began' do
        expect(card.cycle_time).to be_within(2).of(3600)
      end
    end

    context 'when completed_at is not set' do
      let(:card) { create :card, started_at: 1.hour.ago, created_at: 2.hours.ago }

      it 'returns zero' do
        expect(card.cycle_time).to eq 0
      end
    end

    context 'when started_at is not set' do
      let(:card) { create :card, completed_at: Time.now, created_at: 2.hours.ago }

      it 'returns zero' do
        expect(card.cycle_time).to eq 0
      end
    end
  end


  describe '#lead_time' do
    context 'when completed_at is set' do
      let(:card) { create :card, completed_at: Time.now, created_at: 2.hours.ago }

      it 'returns the time taken to complete card since its creation' do
        expect(card.lead_time).to be_within(2).of(7200)
      end
    end

    context 'when completed_at is not set' do
      let(:card) { create :card }

      it 'returns zero' do
        expect(card.lead_time).to eq 0
      end
    end
  end
end
