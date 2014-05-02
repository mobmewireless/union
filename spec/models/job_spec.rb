require 'spec_helper'

describe Job do
  describe '#refresh' do
    subject { create :job, job_type: Job::TYPE_REFRESH }
    let(:refresh) { double Union::Refresh, refresh: nil }

    before do
      allow(Union::Refresh).to receive(:new).and_return refresh
    end

    it 'creates an instance of Union::Refresh, passing the job' do
      Union::Refresh.should_receive(:new).with(subject)
      subject.refresh
    end

    it 'calls refresh on new instance' do
      expect(refresh).to receive(:refresh)
      subject.refresh
    end

    context 'when refresh operation raises Union::DeployerError' do
      it 'sets job status to failure' do
        allow(refresh).to receive(:refresh).and_raise(Exceptions::RefreshError)
        subject.refresh
        expect(subject.status).to eq Job::STATUS_FAILURE
      end
    end
  end
end
