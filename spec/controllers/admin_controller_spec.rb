require 'spec_helper'

describe AdminController do
  include AuthenticationHelpers

  before do
    login_as_admin!
  end


  describe 'POST refresh_boards' do
    before do
      allow(Board).to receive(:refresh!)
    end

    it 'calls Board.refresh!' do
      expect(Board).to receive(:refresh!)
      post :refresh_boards
    end

    it 'calls and renders index' do
      post :refresh_boards
      expect(assigns(:controls)).to_not be_nil
      expect(response).to render_template(:index)
    end
  end
end
