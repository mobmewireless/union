require 'spec_helper'
require 'rake'

describe 'trello namespace rake tasks' do
  describe 'trello:sync' do
    before do
      load File.expand_path('../../../lib/tasks/trello_sync.rake', __FILE__)
      Rake::Task.define_task(:environment)
    end

    it 'should start sync operation for supplied board ID' do
      board_id = rand 10000
      Union::Trello::Synchronizer.should_receive(:sync!).with(board_id)
      Rake::Task['trello:sync'].invoke(board_id.to_s)
    end
  end
end