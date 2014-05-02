require 'spec_helper'

describe Project do
  subject { create :project }

  describe '.filter_with' do
    context 'when params contains inactive_projects' do
      let(:project_1) { create :project }
      let(:project_2) { create :project }
      let(:project_3) { create :project }
      let(:deployment_1) { create :deployment, project: project_1 }
      let(:deployment_2) { create :deployment, project: project_1 }
      let(:deployment_3) { create :deployment, project: project_2 }
      let(:deployment_4) { create :deployment, project: project_3 }

      before do
        Project.any_instance.stub :refresh

        create :job, deployment: deployment_1, created_at: 1.month.ago
        create :job, deployment: deployment_2, created_at: 8.months.ago
        create :job, deployment: deployment_3, created_at: 4.months.ago
        create :job, deployment: deployment_4, created_at: 7.months.ago
      end

      it 'returns projects that contain deployments without jobs since supplied time' do
        response = Project.filter_with(not_deployed_for: 6.months.ago.to_s)
        expect(response - [project_3, project_1]).to be_empty
      end
    end
  end

  describe '.card_tags' do
    before :each do
      # Let's not try to contact imaginary git URL-s.
      Project.any_instance.stub :refresh

      # Create some projects.
      @project_1 = create :project, project_name: 'PROJECT_100'
      @project_2 = create :project, project_name: 'PROJECT_201'
    end

    it 'returns hash mapping project names to ID-s' do
      expect(Project.card_tags).to eq({ 'PROJECT_100' => { project_id: @project_1.id }, 'PROJECT_201' => { project_id: @project_2.id } }.with_indifferent_access)
    end
  end

  describe '#refresh' do
    before do
      allow_any_instance_of(Job).to receive(:refresh)
    end

    context 'when there is an incomplete refresh job' do
      it 'sets an error to project' do
        create :job, job_type: Job::TYPE_REFRESH, project: subject
        subject.refresh('requested_by_someone')
        expect(subject.errors).to_not be_empty
      end
    end

    context 'when there is no incomplete refresh job' do
      it 'creates a refresh job' do
        subject.refresh('requested_by_someone')
        last_refresh_job = Job.where(job_type: Job::TYPE_REFRESH).last
        expect(last_refresh_job.project).to eq subject
        expect(last_refresh_job.requested_by).to eq 'requested_by_someone'
        expect(last_refresh_job.authorized_by).to eq 'requested_by_someone'
      end

      it 'calls refresh on job' do
        expect_any_instance_of(Job).to receive(:refresh)
        subject.refresh('requested_by_someone')
      end

      it 'returns job' do
        expect(subject.refresh('requested_by_someone')).to be_kind_of(Job)
      end
    end
  end
end
