class AdminController < ApplicationController
  before_filter :require_admin

  def index
    @controls = {
      refresh_projects_button: Delayed::Job.where(queue: 'refresh_all').empty? ? {} : { disabled: 'disabled' },
      add_projects_button: Delayed::Job.where(queue: 'add_multiple').empty? ? {} : { disabled: 'disabled' }
    }
    @orphaned_servers = Server.orphaned_servers
    @delayed_jobs = Delayed::Job.all
    @boards = Board.all
  end

  def refresh_projects
    Project.refresh_all
  end

  def add_projects
     begin
       Project.add_multiple JSON.parse(params[:projects_json])
    rescue JSON::ParserError
      @status = :json_parser_error
    end
  end

  def refresh_boards
    Board.refresh!

    # Now render index.
    index && render(:index)
  end
end
