require 'spec_helper'

module Union
  describe ServerConnection do
    subject { ServerConnection.new('server', {host: 'localhost', username: 'deploy', port: 22})}
    let(:path) { double('path') }
    let(:logger) { double 'Log', info: nil, debug: nil }

    before do
      Union::Log.logger = logger
    end

    describe '#execute_logger' do
      it 'executes OSSEC collector' do
        expect(subject).to receive(:execute).with('python /tmp/collector.py')
        subject.execute_logger
      end
    end
  end
end