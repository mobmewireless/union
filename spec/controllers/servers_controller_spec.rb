require 'spec_helper'

describe ServersController do
  include AuthenticationHelpers

  before :each do
    login_as_admin!
  end

  describe "GET 'index'" do
    it 'assigns @new_server' do
      get :index
      expect(assigns(:server)).to be_instance_of(Server)
    end
  end

  describe "POST 'create'" do
    it 'creates new server' do
      post :create, server: { hostname: 'SERVER_HOSTNAME' }
      last_server = Server.last
      expect(last_server.hostname).to eq 'SERVER_HOSTNAME'
      expect(last_server.manually_created?).to be true
    end

    it 'renders index' do
      post :create, server: { hostname: 'SERVER_HOSTNAME' }
      expect(response).to render_template :index
    end
  end

  describe "PATCH 'update'" do
    it 'updates attributes of supplied server' do
      server = create :server
      patch :update, id: server.id, server: { hostname: 'updated hostname' }
      server.reload
      expect(server.hostname).to eq 'updated hostname'
    end
  end
end
