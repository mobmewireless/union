class Deployment < ActiveRecord::Base
  belongs_to :project
  belongs_to :server
  has_many :jobs

  # Creates a new Job entry and calls the deploy method on it
  def deploy(requested_by, opts={ admin: false })
    authorized_by = requested_by if opts[:admin]
    new_job(Job::TYPE_DEPLOY, requested_by, authorized_by).tap { |j| j.deploy }
  end

  # Creates a new Job entry and calls the setup method on it
  def setup(requested_by, opts={ admin: false })
    authorized_by = requested_by if opts[:admin]
    new_job(Job::TYPE_SETUP, requested_by, authorized_by).tap { |j| j.setup }
  end

  def self.settings_hash(settings)
    Digest::SHA1.hexdigest(Hash[settings.sort].to_json)
  end

  private

  # Create and save new Job of supplied type and return it.
  # @param [Integer] job_type 0 for setup and 1 for deploy
  # @return [Job] activerecord Job object
  def new_job(job_type, requested_by, authorized_by)
    Job.new(
      deployment_id: id,
      job_type: job_type,
      requested_by: requested_by,
      authorized_by: authorized_by,
      project_id: self.project_id
    ).tap { |j| j.save! }
  end
end
