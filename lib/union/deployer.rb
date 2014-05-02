require_relative 'log'
require_relative '../exceptions'
require_relative 'executor'
require_relative 'server_connection'
require_relative 'cache'
require_relative 'config'

module Union
  class Deployer
    # Initialization
    def initialize(job, opts={})
      # First, wipe all cached data, so that this process doesn't carry anything from last run.
      reset_everything!

      Config.job = job
      Config.log_level = Logger::DEBUG
      #Log.log_level = opts[:debug] ? DEBUG : INFO

      Log.debug "Initialization complete."
    end

    # Setup process for new application deployments.
    def setup
      Config.job.set_status Job::STATUS_WORKING

      Cache.clone_or_update_repository

      final_status = on_remote_server do |connection, server_options|
        shared_folder_path = File.join(server_options['deployment_path'], "shared")

        # Make sure that deployment path doesn't exist already.
        connection.verify_deploy_dir_non_existent

        # Create the shared folder at deployment path.
        connection.make_directory shared_folder_path

        # Add group write permissions to shared folder.
        connection.chmod 'g+w', shared_folder_path

        # Execute after_setup.
        hook_name = server_options['after_setup'] || 'after_setup' # Untested
        connection.hook_exec(hook_name, "#{Cache.repository_path}/deploy/#{hook_name}", server_options['deployment_path'], copy_before_exec: true)
      end

      Config.job.set_status final_status
    end

    def deploy
      Config.job.set_status Job::STATUS_WORKING

      Cache.clone_or_update_repository

      final_status = on_remote_server do |connection, server_options|
        deployment_directory_path = File.join(server_options['deployment_path'], deployment_directory_name)
        current_directory_path = File.join(server_options['deployment_path'], 'current')
        remote_cache_directory_path = File.join(server_options['deployment_path'], 'cache')

        # Ensure that remote cache directory is present.
        connection.ensure_cache_directory_exists

        # Sync repository files to remote cache directory.
        sync_folder Cache.repository_path, "#{server_options['username']}@#{server_options['host']}:#{remote_cache_directory_path}", (server_options['port'] || 22).to_i

        # Copy non-existent shared files from remote cache to shared directory.
        connection.sync_shared_items

        # Copy remote cache directory to deployment directory.
        connection.copy remote_cache_directory_path, deployment_directory_path

        # Link all shared items.
        connection.link_shared_items deployment_directory_path

        # Execute after_upload from deployment directory path.
        hook_name = server_options['after_upload'] || 'after_upload' # Untested
        connection.hook_exec "deploy/#{hook_name}", "#{Cache.repository_path}/deploy/#{hook_name}", deployment_directory_path

        # Point remote server's 'current' symlink to latest deployment directory.
        connection.symbolic_link(deployment_directory_path, current_directory_path)

        # Execute after_deploy from 'current' directory path.
        hook_name = server_options['after_deploy'] || 'after_deploy' # Untested
        connection.hook_exec "deploy/#{hook_name}", "#{Cache.repository_path}/deploy/#{hook_name}", current_directory_path
      end

      Config.job.set_status final_status
    end

    private

    # Returns the name of the directory to which current deploy is targeted.
    def deployment_directory_name
      @deployment_directory_name ||= "#{Config.deployment_name}-#{Cache.repository_revision}-#{Time.now.strftime '%Y%m%d-%H%M%S%L'}"
    end

    # Rsync contents of origin folder to remote folder.
    def sync_folder(origin, destination, port)
      Log.info 'Synchronizing local cache to remote cache...'

      Executor.execute "rsync -avz --delete --exclude=.git/ -e \"ssh -p #{port}\" #{origin}/ #{destination}"
    end

    # Logs error that occured on remote server..
    def log_error(e)
      Log.error "#{e.message}"
      Log.error "#{e.backtrace.join("\n")}"
    end

    # Yields an SSH connection to remote server
    def on_remote_server
      opts = Cache.deployment_settings['servers'][Config.deployment_name]

      if opts.nil?
        error_message = 'Loaded project configuration does not contain server referred by database. Try refreshing project data before retrying.'
        Log.error error_message
        raise Exceptions::DeployerError, error_message
      end

      opts.reverse_merge!(
        'host' => Config.deployment_name,
        'port' => 22,
        'username' => 'deploy'
      )

      Log.debug opts.to_json

      Log.info "#{Config.host}: Creating SSH connection..."

      conn = ServerConnection.new(Config.deployment_name, opts)

      begin
        yield conn, opts
      rescue => e
        log_error e
        return Job::STATUS_FAILURE
      end

      Job::STATUS_SUCCESS
    end

    def reset_everything!
      @deployment_directory_name = nil

      Config.reset_everything!
      Log.reset_everything!
      Cache.reset_everything!
    end
  end
end
