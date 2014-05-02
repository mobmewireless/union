class ProjectsDatatable
  delegate :params, :link_to, :git_display_url, :shorten_if_required, :render, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Project.count,
      iTotalDisplayRecords: projects_datatable.total_entries,
      aaData: data
    }
  end

  private

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def data
    projects_datatable.map do |project|
      [
        project_name(project),
        git_url(project),
        project_branch(project),
        project.cached_directory,
        project_actions(project)
      ]
    end
  end

  def projects_datatable
    @projects ||= begin
      Project.filter_with(params).page(page).per_page(per_page)
    end
  end

  def project_name(project)
    link_to project.project_name, project
  end

  def git_url(project)
    git_display_url(project.git_url)
  end

  def project_branch(project)
    shorten_if_required(project.branch, 6)
  end

  def project_actions(project)
    render partial: 'projects/projects_actions', formats: [:html], locals: { project: project }
  end
end
