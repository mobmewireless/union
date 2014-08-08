require 'spec_helper'

module Union::ServerLogger
  describe Collector do
    describe '#run' do
      let(:server_1) { create :server, logging: true, login_user: 'deploy', port: 22 }
      let(:server_2) { create :server, logging: true, login_user: 'deploy', port: 22 }
      let(:server_3) { create :server, logging: false }
      let(:server_1_logs) { double 'Server 1 Logs' }
      let(:server_2_logs) { double 'Server 2 Logs' }

      before :each do
        allow(subject).to receive(:run_and_collect_logs).with(server_1).and_return(server_1_logs)
        allow(subject).to receive(:run_and_collect_logs).with(server_2).and_return(server_2_logs)
        allow(subject).to receive(:save_logs)
        allow(subject).to receive(:every).and_yield
      end

      context 'logging is turned off' do
        it 'does not run and collect log from server' do
          expect(subject).to_not receive(:run_and_collect_logs).with(server_3)
          subject.run
        end
      end

      context 'logging is turned on' do
        it 'calls run_and_collect_logs for servers' do
          expect(subject).to receive(:run_and_collect_logs).with(server_1)
          expect(subject).to receive(:run_and_collect_logs).with(server_2)
          subject.run
        end

        it 'calls save_logs for servers' do
          expect(subject).to receive(:save_logs).with(server_1_logs, server_1)
          expect(subject).to receive(:save_logs).with(server_2_logs, server_2)
          subject.run
        end
      end
    end

    describe '#run_and_collect_logs' do
      let(:server) { create :server, logging: true, port: 22, login_user: 'deploy' }
      let(:server_params) {
        HashWithIndifferentAccess.new(
            host: server.hostname,
            username: server.login_user,
            port: server.port
        )
      }

      let(:path) { Pathname.new('lib/union/server_logger/collector.py').realpath }
      let(:mock_connection) { double 'Server Connection', execute_logger: nil }

      before do
        allow(Union::ServerConnection).to receive(:new).and_return(mock_connection)
      end

      it 'creates an instance of ServerConnection' do
        expect(Union::ServerConnection).to receive(:new).with(server.hostname, server_params)
        subject.run_and_collect_logs(server)
      end

      it 'calls execute_logger method of ServerConnection instance' do
        expect(mock_connection).to receive(:execute_logger).with(path)
        subject.run_and_collect_logs(server)
      end

      context 'when execute_logger raises SocketError' do
        it 'logs the event' do
          allow(mock_connection).to receive(:execute_logger).and_raise(SocketError)
          expect(Union::Log).to receive(:error).with(/SocketError/)
          subject.run_and_collect_logs(server)
        end
      end
    end

    describe '#save_logs' do
      let(:logs) {
        { '1394689437.40137' => ['2014 Mar 13 11:13:57 work->/var/log/syslog',
                                 'Mar 13 11:13:55 work ovpn-client[1394]: SIGUSR1[soft,tls-error] received, process restarting'],
          '1394691671.68748' => ['2014 Mar 13 11:51:11 work->/var/log/syslog',
                                 'Rule: 1002 (level 2) Unknown problem somewhere in the system.',
                                 'Mar 13 11:51:10 work ovpn-client[1394]: SIGUSR1[soft,tls-error] received, process restarting'],
          '1394687015.8519' => ['2014 Mar 13 10:33:35 work->/var/log/syslog',
                                'Rule: 1002 (level 2) Unknown problem somewhere in the system.',
                                'Mar 13 10:33:33 work ovpn-client[1394]: TLS Error: TLS handshake failed']
        }
      }
      let(:server) { create :server }

      context 'all unique' do
        it 'saves all entries' do
          subject.save_logs(logs.to_json, server)
          expect(server.server_logs.where(timestamp: %w(1394689437.40137 1394691671.68748 1394687015.8519)).count).to eq 3
          target_log = ServerLog.where(timestamp: '1394689437.40137').first
          expect(target_log.log[0]).to eq logs['1394689437.40137'][0]
          expect(target_log.log[1]).to eq logs['1394689437.40137'][1]
        end
      end

      context 'repeated entries' do
        let(:logs_previous) {
          { '1394689437.40137' => ['2014 Mar 13 11:13:57 work->/var/log/syslog',
                                   'Mar 13 11:13:55 work ovpn-client[1394]: SIGUSR1[soft,tls-error] received, process restarting'],
            '1394691671.68748' => ['2014 Mar 13 11:51:11 work->/var/log/syslog',
                                   'Rule: 1002 (level 2) Unknown problem somewhere in the system.',
                                   'Mar 13 11:51:10 work ovpn-client[1394]: SIGUSR1[soft,tls-error] received, process restarting'],
            '1394691671.88888' => ['2014 Mar 13 11:51:11 work->/var/log/syslog',
                                   'Rule: 1002 (level 2) Unknown problem somewhere in the system.',
                                   'Mar 13 11:51:10 work ovpn-client[1394]: SIGUSR1[soft,tls]test blaaaahhhhhhhhh']
          }
        }

        before { subject.save_logs(logs.to_json, server) }

        it "won't save previously saved entries" do
          subject.save_logs(logs_previous.to_json, server)
          expect(server.server_logs.count).to eq(4)
        end
      end
    end
  end
end
