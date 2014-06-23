class ProjectsController < ApplicationController
  before_filter :require_admin, only: %w(create update destroy deploy setup)

  # GET /projects
  def index
    @filter = params[:not_deployed_for] if params.include? :not_deployed_for
    @new_project = Project.new

    respond_to do |format|
      format.html
      format.json { render json: ProjectsDatatable.new(view_context) }
    end
  end

  # POST /projects
  def create
    @project = Project.new(params[:project])
    @project.save
    @project.refresh(session[:authenticated]['info']['email'].strip)
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])
    @deployments = @project.deployments
    @cards = @project.cards.order('updated_at DESC').limit(100)
  end

  # PUT /projects/:id
  def update
    @project = Project.find(params[:id])
    @project.update_attributes(params[:project])
  end

  # DELETE /projects/:id
  def destroy
    project = Project.find(params[:id])
    @project_id = project.id

    if project.destroy
      flash[:alert] = 'Deleted Project'
    else
      flash[:alert] = project.errors.full_messages
    end
    redirect_to action: :index, status: 303
  end

  def deploy
    project = Project.find(params[:id])
    project.deploy(session[:authenticated]['info']['email'].strip, admin: view_context.admin?)
  end

  def setup
    project = Project.find(params[:id])
    project.setup(session[:authenticated]['info']['email'].strip, admin: view_context.admin?)
  end

  # POST /projects/:id/refresh
  def refresh
    project = Project.find(params[:id])
    job = project.refresh(session[:authenticated]['info']['email'].strip)

    if project.errors.empty?
      flash[:notice] = "Refresh <a href='#{job_url(job)}'>job</a> has been created!".html_safe
    else
      flash[:alert] = project.errors.full_messages
    end

    redirect_to projects_url
  end
end
