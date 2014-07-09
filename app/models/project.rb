class Project < ActiveRecord::Base
  attr_accessible :project_name, :git_url, :branch

  has_many :deployments, dependent: :delete_all
  has_many :servers, through: :deployments
  has_many :jobs

  has_many :card_tags, as: :target
  has_many :cards, through: :card_tags

  before_save :default_values

  validates :project_name, uniqueness: true
  validates :git_url, presence: true
  validate :git_url_must_be_valid

  def self.filter_with(params)
    filtered = if params[:not_deployed_for] && !params[:not_deployed_for].strip.empty?
      deployment_ids = Job.where('created_at > :since_time', since_time: Time.parse(params[:not_deployed_for])).pluck(:deployment_id).uniq
      not_deployed_ids = Deployment.pluck(:id) - deployment_ids
      project_ids = Deployment.where(id: not_deployed_ids).pluck(:project_id)
      Project.where id: project_ids
    else
      all
    end

    searched = if params[:sSearch]
      filtered.where('project_name LIKE :search_string OR git_url like :search_string', search_string: "%#{params[:sSearch]}%")
    else
      filtered
    end

    searched
  end

  # Returns project names and ID-s, suitable for caching.
  #
  # @return [Hash] Project name to ID mapping
  def self.card_tags
    select('id, project_name').inject({}) do |hash, p|
      hash[p.project_name] = { project_id: p.id }
      hash
    end.with_indifferent_access
  end

  ######################
  # VALIDATION METHODS #
  ######################

  # Sets branch to master if nothing has been supplied.
  def default_values
    self.branch = 'master' if self.branch.empty?
  end

  # Allows only git or http[s] clone URLs.
  #
  # TODO Spec Project#git_url_must_be_valid
  def git_url_must_be_valid
    matched = false

    [/^https?:\/\/.+\.git$/i, /^git@.+:.+\.git$/i].each do |valid_form|
      if valid_form.match git_url
        matched = true
        break
      end
    end

    unless matched
      errors.add(:git_url, 'must be of form http[s]://host/path/to/repository.git OR git@host:path/to/repository.git')
    end
  end

  #######################
  # INFORMATION METHODS #
  #######################

  # Returns generated name of cache directory.
  #
  # @return [String] 7-character hex string unique to git URL and branch
  def cached_directory
    case branch
      when 'master'
        Digest::MD5.hexdigest(git_url)[0..6]
      else
        Digest::MD5.hexdigest(git_url + branch)[0..6]
    end
  end

  # Returns full path at which git repository is (to be) cached.
  #
  # @return [String] Absolute path to cached repository
  def cache_repository_path
    File.absolute_path(File.join(Rails.root, 'cache', cached_directory))
  end

  # Returns the path to the union file in cached repository. Raises error if it doesn't exist.
  #
  # @return [String] Absolute path to config file in cached repository
  def union_file_path
    extension = %w(yaml yml).select { |ext| File.exists?("#{cache_repository_path}/deploy/config.#{ext}") }

    if extension.empty?
      nil
    else
      "#{cache_repository_path}/deploy/config.#{extension.first}"
    end
  end

  # Loads deployment settings from repository's union file into instance variable.
  def deployment_settings
    return unless union_file_path

    YAML.load(File.open(union_file_path, 'r'))
  end

  # Returns a short revision number for current branch.
  def cache_repository_revision
    logger.info cache_repository_path.inspect
    File.exists?(cache_repository_path) ? `cd #{cache_repository_path} && git rev-parse --short #{branch}`.strip : "<em>uncached</em>".html_safe
  end

  # Refresh project information in database by pulling latest configuration.
  #
  # @param [String] requested_by Identifying string for user requesting refresh
  # @return [Job, NilClass] job, if one has been created. nil, if there are errors.
  def refresh(requested_by)
    # TODO: Create a job and then defer the rest.
    if jobs.incomplete.find_by(job_type: Job::TYPE_REFRESH).nil?
      job = jobs.create!(
        job_type: Job::TYPE_REFRESH,
        requested_by: requested_by,
        authorized_by: requested_by,
      )

      job.refresh
      job
    else
      errors.add(:project, 'already has an ongoing refresh job.')
    end
  end

  ####################
  # DEFERRED METHODS #
  ####################

  class << self
    # Deferred (delayed_job) job to refresh all projects listed in database.
    def refresh_all(requested_by)
      all.each { |project| project.refresh }
    end

    # Deferred (delayed_job) method to add multiple projects supplied as JSON. This is intended as a method of importing
    # project store maintained by Union <v2.
    def add_multiple(projects_data)
      parsed_projects_data = projects_data.inject({}) do |final, key_and_value|
        begin
          final.update(key_and_value[0] => {
            'git_url' => key_and_value[1].is_a?(String) ? key_and_value[1] : key_and_value[1]["git_url"],
            'branch' => key_and_value[1].is_a?(String) ? 'master' : key_and_value[1]["branch"]
          })
        rescue => e
          logger.error "event: 'union_add_multiple_git_url_branch_extraction_failure', error_message: #{e.message}, project_name: #{key_and_value[0]}"
        end
      end

      parsed_projects_data.each do |project_name, project_url_and_branch|
        # Skip this project if it already exists.
        next unless Project.where(project_name: project_name).first.nil?

        new(
          project_name: project_name,
          git_url: project_url_and_branch['git_url'],
          branch: project_url_and_branch['branch']
        ).save
      end

      logger.info 'event: union_add_multiple_complete'
    end

    handle_asynchronously :refresh_all, queue: 'refresh_all'
    handle_asynchronously :add_multiple, queue: 'add_multiple'
  end

  ##############
  # DEPLOYMENT #
  ##############

  # Deploy all deployments belonging to this project
  #
  # @param [String] requested_by e-mail address of person who requested deployment
  # @param [Hash] opts deployment options
  # @option admin [Boolean] true if user is admin - implies automatic authorization of deployment. false otherwise.
  def deploy(requested_by, opts={ admin: false })
    deployments.each { |d| d.deploy requested_by, opts }
  end

  # Setup all deployments belonging to this project
  #
  # @param [String] requested_by e-mail address of person who requested setup
  # @param [Hash] opts setup options
  # @option admin [Boolean] true if user is admin - implies automatic authorization of setup. false otherwise.
  def setup(requested_by, opts={ admin: false })
    deployments.each { |d| d.setup requested_by, opts }
  end
end
