require 'spec_helper'

describe MetricsController do
  include AuthenticationHelpers

  before :each do
    login_as_user!
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  describe 'GET burndown' do
    let(:burndown_report) { double 'Burndown report' }
    let(:board) { create :board }

    before do
      Report.stub burndown_report: burndown_report
    end

    it 'builds burndown report' do
      Report.should_receive(:burndown_report).with(instance_of(Board))
      get :burndown, board_id: board.id
    end

    it 'assigns @burndown' do
      get :burndown, board_id: board.id
      expect(assigns(:burndown)).to eq burndown_report
    end
  end
end
