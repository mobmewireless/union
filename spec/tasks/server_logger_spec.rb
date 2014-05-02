require 'spec_helper'
require 'rake'

describe 'server namespace rake tasks' do
  describe 'server:logger' do
    before do
      load File.expand_path('../../../lib/tasks/server_logger.rake', __FILE__)
      Rake::Task.define_task(:environment)
    end

    it 'runs an instance of collector' do
      mock_collector = double 'collector'
      Union::ServerLogger::Collector.stub new: mock_collector
      expect(mock_collector).to receive(:run)
      Rake::Task['server:logger'].invoke
    end
  end
end