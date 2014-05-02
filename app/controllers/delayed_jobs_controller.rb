class DelayedJobsController < ApplicationController
  def clear
    delayed_jobs = Delayed::Job.all

    delayed_jobs.each do |delayed_job|
      dj_handler = YAML.load(delayed_job.handler)

      # Set the corresponding job to failure
      if dj_handler.respond_to?(:id)
        job_id = dj_handler.id
        job = Job.find(job_id)
        job.set_status(Job::STATUS_CANCELLED)
      end

      delayed_job.delete
    end
  end
end
