require 'spec_helper'

describe Report do
  describe '.burndown!' do
    let(:board_1) { create :board, new_list_id: 'NEW_LIST_ID_1', wip_list_id: 'WIP_LIST_ID_1', done_list_id: 'DONE_LIST_ID_1', trello_webhook_id: 'WEBHOOK_ID_1' }
    let(:board_2) { create :board, new_list_id: 'NEW_LIST_ID_2', wip_list_id: 'WIP_LIST_ID_2', done_list_id: 'DONE_LIST_ID_2', trello_webhook_id: 'WEBHOOK_ID_2'}
    let(:inactive_board) { create :board, new_list_id: 'NEW_LIST_ID_3', wip_list_id: 'WIP_LIST_ID_3', done_list_id: 'DONE_LIST_ID_3'}

    before do
      2.times { create :card, board: board_1, trello_list_id: 'NEW_LIST_ID_1' }
      create :card, board: board_1, trello_list_id: 'NEW_LIST_ID_1', archived: true
      4.times { create :card, board: board_1, trello_list_id: 'WIP_LIST_ID_1' }
      create :card, board: board_1, trello_list_id: 'WIP_LIST_ID_1', deleted: true
      3.times { create :card, board: board_1, trello_list_id: 'DONE_LIST_ID_1' }
      5.times { create :card, board: board_2, trello_list_id: 'NEW_LIST_ID_2' }
      7.times { create :card, board: board_2, trello_list_id: 'WIP_LIST_ID_2' }
      6.times { create :card, board: board_2, trello_list_id: 'DONE_LIST_ID_2' }
      create :card, board: inactive_board, trello_list_id: 'NEW_LIST_ID_3'
      create :card, board: inactive_board, trello_list_id: 'WIP_LIST_ID_3'
      create :card, board: inactive_board, trello_list_id: 'DONE_LIST_ID_3'
    end

    it 'creates entries in the reports table with current counts of new and wip cards for all active boards' do
      described_class.burndown!
      expect(Report.count).to eq 2
      first_report = Report.first
      second_report = Report.last
      expect(first_report.owner).to eq board_1
      expect(second_report.owner).to eq board_2
      expect(first_report.data).to eq({ new: 2, wip: 4 }.with_indifferent_access)
      expect(second_report.data).to eq({ new: 5, wip: 7 }.with_indifferent_access)
    end
  end

  describe '.burndown_report' do
    let(:board) { create :board, new_list_id: 'NEW_LIST_ID', wip_list_id: 'WIP_LIST_ID' }
    let(:another_board) { create :board }

    before do
      create :card, board: board, trello_list_id: 'NEW_LIST_ID'
      create :card, board: board, trello_list_id: 'NEW_LIST_ID', archived: true
      create :card, board: board, trello_list_id: 'NEW_LIST_ID'
      create :card, board: board, trello_list_id: 'WIP_LIST_ID'
      create :card, board: board, trello_list_id: 'WIP_LIST_ID', deleted: true
      create :report, report_type: Report::TYPE_BURNDOWN, owner: board, data: { new: 3, wip: 4 }.with_indifferent_access, created_at: 2.days.ago
      create :report, report_type: Report::TYPE_BURNDOWN, owner: board, data: { new: 4, wip: 2 }.with_indifferent_access, created_at: 14.days.ago
      create :report, report_type: Report::TYPE_BURNDOWN, owner: board, data: { new: 5, wip: 3 }.with_indifferent_access, created_at: 32.days.ago
      create :report, report_type: Report::TYPE_BURNDOWN, owner: another_board, data: { new: 10, wip: 10 }.with_indifferent_access, created_at: 1.day.ago
    end

    it 'returns reports since supplied time and latest report' do
      br = described_class.burndown_report(board)
      expect(br[:new].keys.sort[0]).to be_within(2).of(14.days.ago)
      expect(br[:new].keys.sort[1]).to be_within(2).of(2.days.ago)
      expect(br[:new].keys.sort[2]).to be_within(2).of(Time.now)
      expect([2, 3, 4] - br[:new].values).to be_empty
      expect(br[:wip].keys.sort[0]).to be_within(2).of(14.days.ago)
      expect(br[:wip].keys.sort[1]).to be_within(2).of(2.days.ago)
      expect(br[:wip].keys.sort[2]).to be_within(2).of(Time.now)
      expect([1, 4, 2] - br[:wip].values).to be_empty
    end
  end
end
