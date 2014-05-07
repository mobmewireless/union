# @author Hari Gopal <mail@harigopal.in>
class Job < ActiveRecord::Base
  attr_accessible :deployment_id, :job_type, :requested_by, :authorized_by,
                  :project_id

  belongs_to :deployment
  belongs_to :project
  has_many :job_logs

  before_save :default_values

  # Valid values for status field.
  STATUS_QUEUED  = 0
  STATUS_WORKING = 1 # TODO: STATUS_WORKING probably isn't enough. There are a lot of intermediary states that can / should be captured for display on Jobs page.
  STATUS_SUCCESS = 2
  STATUS_FAILURE = 3
  STATUS_CANCELLED = 4

  scope :incomplete, -> { where(status: [STATUS_QUEUED, STATUS_WORKING]) }

  # Sets status to supplied value.
  def set_status(s)
    self.status = s
    save
  end

  def project
    super || deployment.try(:project)
  end

  # Gets a user-understandable string for status value.
  def status_html
    case status
      when STATUS_QUEUED
        '<span class="label label-default">Queued</span>'.html_safe
      when STATUS_WORKING
        '<span class="label label-info">Processing</span>'.html_safe
      when STATUS_SUCCESS
        '<span class="label label-success">Success</span>'.html_safe
      when STATUS_FAILURE
        '<span class="label label-danger">Failure</span>'.html_safe
      when STATUS_CANCELLED
        '<span class="label label-warning">Cancelled</span>'.html_safe
      else
        '<span class="label label-inverse">Unknown</span>'.html_safe
    end
  end

  def complete?
    !([STATUS_QUEUED, STATUS_WORKING].include? status)
  end

  # Valid values for job_type field.
  TYPE_SETUP  = 0
  TYPE_DEPLOY = 1
  TYPE_REFRESH = 2

  def job_type_html
    case job_type
      when Job::TYPE_DEPLOY
        '<span class="label label-success">Deploy</span>'.html_safe
      when Job::TYPE_SETUP
        '<span class="label label-primary">Setup</span>'.html_safe
      when Job::TYPE_REFRESH
        '<span class="label label-primary">Refresh</span>'.html_safe
      else
        '<span class="label label-default">Unknown</span>'.html_safe
    end
  end

  ######################
  # VALIDATION METHODS #
  ######################

  # Sets job status to queued if nothing's supplied
  def default_values
    self.status = STATUS_QUEUED if self.status.nil?
  end

  ##############
  # DEPLOYMENT #
  ##############

  # Deferred (delayed_job) call to a deploy method of a new Deployer Instance
  #
  # @see Union::Deployer
  def deploy
    begin
      Union::Deployer.new(self).deploy
    rescue Exceptions::DeployerError
      self.status = STATUS_FAILURE
      save!
    end
  end

  # Deferred (delayed_job) call to a setup method of a new Deployer Instance
  #
  # @see Union::Deployer
  def setup
    begin
      Union::Deployer.new(self).setup
    rescue Exceptions::DeployerError
      self.status = STATUS_FAILURE
      save!
    end
  end

  handle_asynchronously :deploy, queue: 'setup_and_deploy'
  handle_asynchronously :setup, queue: 'setup_and_deploy'

  # Asynchronous refresh job, which pulls latest git version, and updates configuration in local database.
  def refresh
    begin
      Union::Refresh.new(self).refresh
    rescue Exceptions::UnionError
      self.status = STATUS_FAILURE
      save!
    end
  end

  handle_asynchronously :refresh, queue: 'refresh'

  ########
  # LOGS #
  ########

  def log_file_path
    month = created_at.in_time_zone('Kolkata').strftime('%Y_%m')
    File.join("#{Rails.root}", 'log', 'jobs', month, "job_#{id}.log")
  end

  def load_log_lines
    logger.debug log_file_path

    if File.exists? log_file_path
      `tail -1024 #{log_file_path}`.strip.split(/\n/)
    else
      ["Log file doesn't exist (yet?)"]
    end
  end
end
