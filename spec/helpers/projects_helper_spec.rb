require 'spec_helper'

describe ProjectsHelper do
  describe '#git_display_url' do
    context 'when supplied a standard https clone URL' do
      it 'returns link to repository with extracted components' do
        git_clone_url = 'https://git.my-company.com/cool_project/super-dup3r_repo.git'
        expect(helper.git_display_url(git_clone_url)).to eq "<a href='https://git.my-company.com/cool_project/super-dup3r_repo' title='#{git_clone_url}'>super-dup3r_repo</a>"
      end
    end

    context 'when supplied a standar git clone URL' do
      it 'returns link to repository with extracted components' do
        git_clone_url = 'git@git.my-company.com:cool_project/super-dup3r_repo.git'
        expect(helper.git_display_url(git_clone_url)).to eq "<a href='https://git.my-company.com/cool_project/super-dup3r_repo' title='#{git_clone_url}'>super-dup3r_repo</a>"
      end
    end

    context 'when supplied an unparseable clone URL' do
      it 'returns the supplied string' do
        git_clone_url = 'http://git.my-company.com/custom_r3po.git'
        expect(helper.git_display_url(git_clone_url)).to eq git_clone_url
      end
    end
  end

  describe '#since_last_job' do
    it 'returns time since last job as abbr' do
      Project.any_instance.stub :refresh
      job = create :job, created_at: 2.months.ago
      expect(helper.since_last_job(job)).to eq "<abbr title=#{job.created_at.iso8601}>2 months ago</abbr>"
    end
  end
end
