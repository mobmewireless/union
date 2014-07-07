require 'spec_helper'

describe ProjectsController do
  include AuthenticationHelpers

  before do
    login_as_user!
  end

  describe "GET 'index'" do
    it 'assigns @new_project' do
      get :index
      expect(assigns(:new_project)).to be_instance_of(Project)
    end
  end

  describe 'POST refresh' do
    let(:project) { create :project }
    let(:job) { create :job }

    before :each do
      allow_any_instance_of(Project).to receive(:refresh)
      allow(Project).to receive(:find).with(project.id.to_s).and_return(project)
      allow(project).to receive(:refresh).and_return(job)
    end

    it 'calls refresh on supplied project' do
      expect(project).to receive(:refresh).with(test_user.email)
      post :refresh, id: project.id
    end

    context 'when project does not contain errors' do
      it 'flashes success message' do
        post :refresh, id: project.id
        expect(flash[:notice]).to_not eq(nil)
      end
    end

    context 'when the project contains errors' do
      it 'flashes alert message' do
        project.errors.add :project, 'has some error'
        post :refresh, id: project.id
        expect(flash[:alert]).to_not eq(nil)
      end
    end

    it 'redirects to projects page' do
      post :refresh, id: project.id
    end
  end
end
