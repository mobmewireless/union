require 'spec_helper'

module Union
  describe ServerConnection do
    subject { ServerConnection.new('server', {host: 'localhost', username: 'deploy', port: 22})}
    let(:path) { double('path') }
    let(:logger) { double 'Log', info: nil }

    before do
      Union::Log.logger = logger
    end

    describe '#execute_logger' do
      it 'executes OSSEC collector' do
        allow(subject).to receive(:path_exists?).and_return(true)
        expect(subject).to receive(:execute).with(path)
        subject.execute_logger(path)
      end

      context 'when OSSEC collector does not exist' do
        it 'raises ServerLoggerExecutableMissing' do
          allow(subject).to receive(:path_exists?).and_return(false)
          expect{ subject.execute_logger(path) }.to raise_error(Exceptions::ServerLoggerExecutableMissing)
        end
      end
    end
  end
end