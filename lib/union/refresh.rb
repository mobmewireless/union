require_relative 'config'
require_relative 'log'
require_relative 'cache'

module Union
  class Refresh
    # @param [Job] job
    def initialize(job)
      Config.job = job
      Config.log_level = Logger::DEBUG

      reset_everything!

      Log.debug 'Refresh initialization complete.'
    end

    # Main refresh method. Call this.
    def refresh
      Config.job.set_status Job::STATUS_WORKING
      Cache.clone_or_update_repository
      config = begin
        YAML.load_file Cache.config_file_path
      rescue Psych::SyntaxError
        message = 'Could not parse deployment configuration! Please verify correctness before trying to refresh.'
        Log.error message
        raise Exceptions::RefreshError, message
      end
      begin
        deployments = config['servers'].inject({}) do |deployments, deployment_config|
          deployments[deployment_config[0]] = server_info(deployment_config[0], deployment_config[1])
          deployments
        end

        finish(deployments)

        Log.info 'All done. Project details have been updated.'
        Config.job.set_status Job::STATUS_SUCCESS
      rescue => e
        message = 'Error occurred while trying to extract deployment information from configuration file. Please see following error lines for information:'
        Log.error message
        Log.error e.message
        Log.error e.backtrace
        raise Exceptions::RefreshError, message
      end
    end

    # Completes the refresh process by processing deployment entries from the cloned / updated config YAML, going
    # through each and updating database entries for deployments.
    #
    # @param [Hash] deployments
    def finish(deployments)
      current_deployments = []
      project = Config.job.project

      deployments.each do |deployment_name, deployment_settings|
        Log.debug "Verifying deployment details of '#{deployment_name}'."
        current_deployments << deployment_name

        # Attempt to fetch the server.
        server = Server.where(hostname: deployment_settings[:hostname]).first

        # If server doesn't exist, create it.
        if server.nil?
          server = Server.new(hostname: deployment_settings[:hostname])
          server.save
        end

        # Search for a deployment
        deployment = Deployment.where(deployment_name: deployment_name, project_id: project.id).first

        if deployment.nil?
          # Create deployment, if missing.
          new_deployment = project.deployments.new(
            deployment_settings.slice(:deployment_path, :login_user, :port).merge(
              deployment_name: deployment_name,
              settings_hash: Deployment.settings_hash(deployment_settings)
            )
          )

          new_deployment.server = server
          new_deployment.save
        elsif Deployment.settings_hash(deployment_settings) != deployment.settings_hash
          # Or update it if the settings have changed
          deployment.update_attributes(
            deployment_settings.slice(:deployment_path, :login_user, :port).merge(
              deployment_name: deployment_name,
              settings_hash: Deployment.settings_hash(deployment_settings)
            )
          )

          deployment.server = server
          deployment.save
        end
      end

      # Delete deployments that are no longer listed in YAML.
      Deployment.where('deployment_name NOT in (?)', current_deployments).where(project_id: project.id).delete_all
    end

    # Extract a server's' information from project's configuration for it.
    def server_info(deployment_name, deployment_config)
     {
       hostname: (deployment_config['host'] || deployment_name),
       deployment_path: deployment_config['deployment_path'],
       login_user: (deployment_config['username'] || 'deploy'),
       port: (deployment_config['port'] || '22')
     }
    end

    # Resets class variables so that they can be reused.
    def reset_everything!
      Config.reset_everything!
      Log.reset_everything!
      Cache.reset_everything!
    end
  end
end