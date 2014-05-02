class JobsController < ApplicationController
  def index
    @jobs = {
      processing: Job.where(status: Job::STATUS_WORKING).order('`id` ASC'),
      queued: Job.where(status: Job::STATUS_QUEUED).order('`id` ASC')
    }

    respond_to do |format|
      format.html
      format.json { render json: JobsDatatable.new(view_context) }
    end
  end

  def show
    @job = Job.find params[:id]
    @lines = @job.load_log_lines
  end

  def logs
    job = Job.find params[:id]
    @lines = job.load_log_lines
    render json: { lines: view_context.labelize(@lines), complete: job.complete? }
  end
end
