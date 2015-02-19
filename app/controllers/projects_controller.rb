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
    @project = Project.new project_params
    @project.save
    @project.refresh(current_user.email)
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])
    @deployments = @project.deployments
    @cards = @project.cards.order('updated_at DESC').limit(100)
  end

  # PUT /projects/:id
  def update
    puts params
    @project = Project.find(params[:id])
    @project.update_attributes(project_params)
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
    project.deploy(current_user.email, admin: view_context.admin?)
  end

  def setup
    project = Project.find(params[:id])
    project.setup(current_user.email, admin: view_context.admin?)
  end

  # POST /projects/:id/refresh
  def refresh
    project = Project.find(params[:id])
    job = project.refresh(current_user.email)

    if project.errors.empty?
      flash[:notice] = "Refresh <a href='#{job_url(job)}'>job</a> has been created!".html_safe
    else
      flash[:alert] = project.errors.full_messages
    end

    redirect_to projects_url
  end

  private
  def project_params
    params.require(:project).permit(:project_name, :git_url, :branch)
  end
end
