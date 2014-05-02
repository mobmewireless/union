class ServersController < ApplicationController
  before_filter :require_admin, only: %w(create update destroy)

  # This is a weird implementation. Shared code between index and create. Refactor if possible.
  def servers_index
    @server = Server.new
  end

  # GET /servers
  def index
    servers_index

    respond_to do |format|
      format.html
      format.json { render json: ServersDatatable.new(view_context) }
    end
  end

  # POST /servers
  def create
    @server = Server.create(server_params.merge(manually_created: true))

    if @server.errors.empty?
      flash.now[:success] = 'Successfully added new server.'
    else
      flash.now[:error] = "There were one or more errors with your request: #{@server.errors.full_messages.map { |m| m.inspect }.join ', '}"
    end

    servers_index && render(:index)
  end

  # PATCH /servers/1
  def update
    server = Server.find params[:id]
    server.update_attributes(server_params)

    if server.errors.empty?
      flash.now[:success] = 'Successfully updated server.'
    else
      flash.now[:error] = "There were one or more errors with your request: #{server.errors.full_messages.map { |m| m.inspect }.join ', '}"
    end

    show && render(:show)
  end

  # GET /servers/1
  def show
    @server = Server.find(params[:id])
    @deployments = @server.deployments
    @cards = @server.cards.order('updated_at DESC').limit(100)
  end

  # DELETE /servers/:id
  def destroy
    @server = Server.find(params[:id])
    @server.destroy if @server.deployments.empty?
  end

  def metrics
    @server = Server.find(params[:id])

    @timing = {
      tbf: @server.time_between_failures(21.weeks.ago, unit: Server::TIME_UNIT_HOUR),
      ttr: @server.time_to_repair(21.weeks.ago, unit: Server::TIME_UNIT_MINUTE),
      logs_and_cards: @server.logs_and_cards_with_timestamp(3.days.ago)
    }
  end

  private

  def server_params
    params.require(:server).permit(:hostname, :port, :logging, :login_user)
  end
end
