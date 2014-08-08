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
      it 'copies OSSEC collector to server' do
        allow_any_instance_of(ServerConnection).to receive(:execute)
        expect(subject).to receive(:remote_copy).with(path, '/tmp/collector.py')
        subject.execute_logger(path)
      end

      it 'executes OSSEC collector' do
        expect(subject).to receive(:remote_copy)
        expect(subject).to receive(:execute).with('/tmp/collector.py')
        subject.execute_logger(path)
      end
    end
  end
end