require 'spec_helper'

# TODO: These specs won't work when run alone via Zeus. Seems to be something wrong with models not getting loaded.
module Union
  describe Refresh do
    def write_valid_config!
      File.open('/path/to/deploy/config.yaml', 'w') do |f|
        f.write('
servers:
  localhost:
    username: deploy
    deployment_path: "/home/username/deploy/test"
  localhost-2:
    username: deploy
    host: localhost
    deployment_path: "/home/username/deploy/test_2"
')
      end
    end

    let(:job) { create :job, job_type: Job::TYPE_REFRESH }
    subject { Refresh.new job }

    # Only the happy path is tested.
    describe '#refresh' do
      before do
        allow(Config).to receive(:job).and_return(job)
        allow(Cache).to receive(:clone_or_update_repository)
        allow(Cache).to receive(:config_file_path).and_return('/path/to/deploy/config.yaml')
        allow(Log).to receive(:error)
      end

      before :all do
        FakeFS.activate!
        FileUtils.mkdir_p '/path/to/deploy'
        write_valid_config!
      end

      after :all do
        FakeFS.deactivate!
      end

      it 'sets job status to working' do
        # Let's force the job to crash, by writing bad YAML into the config, to check whether status working is set.
        File.open('/path/to/deploy/config.yaml', 'w') do |f|
          f.write('foobar')
        end

        expect { subject.refresh }.to raise_error(Exceptions::RefreshError)
        expect(job.status).to eq Job::STATUS_WORKING

        # Restore the configuration file for following tests.
        write_valid_config!
      end

      it 'clones or updates project repository' do
        expect(Cache).to receive(:clone_or_update_repository)
        subject.refresh
      end

      it 'calls finish with parsed deployments information' do
        expect(subject).to receive(:finish).with('localhost' => { hostname: 'localhost', deployment_path: '/home/username/deploy/test', login_user: 'deploy', port: '22' }, 'localhost-2' => { hostname: 'localhost', deployment_path: '/home/username/deploy/test_2', login_user: 'deploy', port: '22' })
        subject.refresh
      end

      it 'sets job status to success' do
        subject.refresh
        expect(job.status).to eq Job::STATUS_SUCCESS
      end
    end

    describe '#finish' do
      let(:deployments) {
        {
          'localhost' => {
            hostname: 'localhost',
            deployment_path: '/home/username/deploy/test',
            login_user: 'username', port: '22'
          },
          'localhost-2' => {
            hostname: 'localhost',
            deployment_path: '/home/username/deploy/test_2',
            login_user: 'username',
            port: '22'
          }
        }
      }

      let(:project) { create :project }
      let(:job) { create :job, project: project }

      before do
        allow(Config).to receive(:job).and_return(job)
      end

      context 'for each deployment' do
        context 'when server does not exist' do
          it 'creates server' do
            subject.finish deployments
            expect(Server.last.hostname).to eq 'localhost'
          end
        end

        context 'when deployment does not exist' do
          before do
            # Let's create one of the deployments, and check for presence of the other.
            create :deployment, project: project, deployment_name: 'localhost'
          end

          it 'creates deployment' do
            subject.finish deployments
            deployment = Deployment.last
            expect(deployment.attributes.slice('deployment_path', 'login_user', 'port', 'deployment_name', 'project_id')).to eq(
              'deployment_path' => '/home/username/deploy/test_2',
              'login_user' => 'username',
              'port' => 22,
              'deployment_name' => 'localhost-2',
              'project_id' => project.id
            )
          end
        end

        context 'when deployment exists with different settings' do
          let!(:second_deployment) { create :deployment, project: project, deployment_name: 'localhost-2', deployment_path: '/home/username/deploy/old_path' }

          before do
            # Let's create both, deployments, but one with different settings.
            create :deployment, project: project, deployment_name: 'localhost'
          end

          it 'updates deployment settings' do
            subject.finish deployments
            second_deployment.reload
            expect(second_deployment.deployment_path).to eq '/home/username/deploy/test_2'
          end
        end
      end

      context 'when existing deployments are no longer configured' do
        # Let's remove one of the deployments passed to finish.
        let(:deployments) {
          {
            'localhost-2' => {
              hostname: 'localhost',
              deployment_path: '/home/username/deploy/test_2',
              login_user: 'username',
              port: '22'
            }
          }
        }

        let!(:deployment_to_be_deleted) { create :deployment, project: project, deployment_name: 'localhost' }

        before do
          create :deployment, project: project, deployment_name: 'localhost-2'
        end

        it 'deletes deployments that are no longer configured' do
          subject.finish deployments
          expect(Deployment.exists?(deployment_to_be_deleted)).to eq false
        end
      end
    end
  end
end