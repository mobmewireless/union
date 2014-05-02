class JobsDatatable

  delegate :params, :link_to, :project_path, :server_path, :email_name, :job_path, :time_ago_in_words, :to => :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Job.where(status: [Job::STATUS_SUCCESS, Job::STATUS_FAILURE, Job::STATUS_CANCELLED]).count,
      iTotalDisplayRecords: jobs_datatable.total_entries,
      aaData: data
    }
  end

  private

  def data
    jobs_datatable.map do |job|
      [
        job.job_type_html,
        job.id,
        project_name(job),
        deployment_name(job),
        deployment_who(job),
        deployment_time(job),
        deployment_status(job)
      ]
    end
  end

  def jobs_datatable
    @jobs_datatable ||= fetch_jobs
  end

  def fetch_jobs
    jobs = Job.where(status: [Job::STATUS_SUCCESS, Job::STATUS_FAILURE, Job::STATUS_CANCELLED]).order('`id` DESC')
    jobs = jobs.page(page).per_page(per_page)

    if params[:sSearch_2].present?
      jobs = jobs.joins(deployment: :project).where('project_name like :name', name: "%#{params[:sSearch_2]}%")
    end

    if params[:sSearch_3].present?
      jobs = jobs.joins(:deployment).where('deployment_name like :name', name: "%#{params[:sSearch_3]}%")
    end

    if params[:sSearch_4].present?
      jobs = jobs.where('requested_by like :name', name: "%#{ params[:sSearch_4] }%")
    end

    if date_format?(params[:sSearch_5])
      date_range = parse_date(params[:sSearch_5])
      jobs = jobs.where(created_at: date_range)
    end

    if params[:sSearch_6]
      case params[:sSearch_6]
        when 'Success'
          jobs = jobs.where(status: 2)
        when 'Failure'
          jobs = jobs.where(status: 3)
        when 'Cancelled'
          jobs = jobs.where(status: 4)
      end
    end

    jobs
  end

  def date_format?(date_string)
    return false if date_string.nil?
    dates = date_array(date_string)
    dates.count == 2 ? true : false
  end

  def parse_date(date_string)
    dates = date_array(date_string)
    (dates.first.to_time)..(dates.last.to_time + 1.day)
  end

  def date_array(date_string)
    date_string.split('~')
  end

  def deployment_name(job)
    if job.deployment
      "#{ link_to(job.deployment.deployment_name, server_path(job.deployment.server)) if job.deployment }".html_safe
    elsif job.job_type == Job::TYPE_REFRESH
      '<em>Not Applicable</em>'.html_safe
    else
      '<em>Deployment Missing</em>'.html_safe
    end
  end

  def deployment_time(job)
    "<abbr title=#{job.created_at.iso8601}>#{time_ago_in_words(job.created_at, include_seconds: false)} ago</abbr>".html_safe
  end

  def deployment_status(job)
    "#{ job.status_html }
    #{ link_to('Logs', job_path(job), class: 'btn btn-info btn-xs') }".html_safe
  end

  def deployment_who(job)
    if job.requested_by == job.authorized_by
      email_name(job.requested_by)
    else
      "#{ email_name(job.requested_by)} <i class='icon-chevron-right'>".html_safe
    end
  end

  def project_name(job)

    if job.project
      "#{ link_to(job.project.project_name, project_path(job.project))}".html_safe
    else
      '<em class="text-center">Can\'t detect project</em>'.html_safe
    end

  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

end
