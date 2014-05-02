require_relative 'log'
require_relative '../exceptions'

module Union
  # Holds actions that can be performed on the remote server.
  class ServerConnection
    attr_reader :connection

    def initialize(name, options)
      @deployment_name = name
      @deployment_settings = options
    end

    def connection
      @connection ||= Net::SSH.start(
        @deployment_settings['host'],
        @deployment_settings['username'],
        port: @deployment_settings['port']
      )
    end

    # Recursively, and forcibly delete supplied 'path'.
    def delete(path)
      execute "rm -rf #{path}"
    end

    # Create directory at supplied 'path'.
    def make_directory(path)
      Log.info "#@deployment_name: Making directory structure '#{path}'..."
      execute "mkdir -p #{path}"
    end

    # Check whether a supplied 'path' exists.
    def path_exists?(path)
      execute("if [ -e #{path} ]; then echo 'exists'; fi").empty? ? false : true
    end

    # Copy all of 'origin' to 'destination'.
    def copy(origin, destination)
      Log.info "#@deployment_name: Copying '#{origin}' to '#{destination}'..."
      execute "cp -a #{origin} #{destination}"
    end

    # Creates a symbolic link to 'target' at 'link_location'.
    def symbolic_link(target, link_location)
      # -s  Symbolic link
      # -f  Force (overwrite)
      # -T  Treat link name as file, even if it is a directory.
      Log.info "#@deployment_name: Creating link to '#{target}' as '#{link_location}'  ..."
      execute "ln -sfT #{target} #{link_location}"
    end

    # Raises error if the deployment directory already exists.
    def verify_deploy_dir_non_existent
      Log.info "#@deployment_name: Verifying non-existence of deployment_path..."

      if path_exists?(@deployment_settings['deployment_path'])
        raise Exceptions::DeployerError, "Deployment path already exists. Can't continue!"
      end
    end

    # Place new shared items in the remote shared folder.
    def sync_shared_items
      return unless @deployment_settings.include? 'shared'

      Log.info "#@deployment_name: Synchronizing shared items..."

      @deployment_settings['shared'].each do |item|
        remote_shared_item_path   = "#{@deployment_settings['deployment_path']}/shared/#{item.gsub '.example', ''}"
        remote_cache_item_path    = "#{@deployment_settings['deployment_path']}/cache/#{item}"

        unless path_exists? remote_shared_item_path
          if item.include? '.example'
            create_base_folder_for_shared item
            copy remote_cache_item_path, remote_shared_item_path
          else
            raise(Exceptions::DeployerError, "Non-example shared item #{item} is git-tracked, and cannot be sym-linked.") if path_exists?(remote_cache_item_path)
            create_base_folder_for_shared item
            create_shared_item remote_shared_item_path
          end

          chmod 'g+w', remote_shared_item_path
        end
      end
    end

    # Creates a non-existent shared-item
    def create_shared_item(item_path)
      if item_path[-1] == '/'
        make_directory(item_path[0..-2])
      else
        touch item_path
      end
    end

    # Creates an empty file at supplied path.
    def touch(file_path)
      Log.info "#@deployment_name: Creating empty file at #{file_path}..."

      execute "touch #{file_path}"
    end

    # Creates a base folder for new shared item, if it doesn't exist already.
    def create_base_folder_for_shared(item)
      parts = item.split('/')[0..-2]
      parts.delete ''
      remote_shared_item_folder_name = parts.join '/'

      return if remote_shared_item_folder_name.empty?

      remote_shared_item_folder_path = "#{@deployment_settings['deployment_path']}/shared/#{remote_shared_item_folder_name}"

      return if path_exists? remote_shared_item_folder_path

      make_directory remote_shared_item_folder_path
    end

    # Creates symbolic links of all shared items to latest deployment directory
    def link_shared_items(deployment_directory)
      return unless @deployment_settings.include? 'shared'

      Log.info "#@deployment_name: Linking shared items..."

      @deployment_settings['shared'].each do |item|
        item = item[0..-2] if item[-1] == '/' # Remove trailing slash for directories.
        shared_item  = "#{@deployment_settings['deployment_path']}/shared/#{item.gsub '.example', ''}"
        symbolic_link shared_item, "#{deployment_directory}/#{item.gsub '.example', ''}"
      end
    end

    # Create the remote cache directory, unless it exists.
    def ensure_cache_directory_exists
      Log.info "#@deployment_name: Verifying existence of cache directory..."
      remote_cache_directory_path = "#{@deployment_settings['deployment_path']}/cache"

      unless path_exists? remote_cache_directory_path
        make_directory(remote_cache_directory_path)
      end
    end

    # Executes hook file, copying it over, if specified.
    def hook_exec(execution_file, cached_hook_path, execution_path, options={})
      Log.debug "Searching for hook at #{cached_hook_path}..."

      if File.exists?(cached_hook_path)
        Log.info "#@deployment_name: Executing hook '#{execution_file}'..."
      else
        Log.info "#@deployment_name: Hook '#{execution_file}' doesn't exist. Skipping.'"
        return
      end

      options.reverse_merge!({copy_before_exec: false})

      # Copy the hook file to remote server if the 'copy_before_exec' option is set.
      remote_copy(cached_hook_path, execution_path) if options[:copy_before_exec]

      # Execute the hook file.
      execute "cd #{execution_path} && chmod +x #{execution_file} && ./#{execution_file}"

      # Delete the hook file from remote server, if it was copied over.
      execute "cd #{execution_path} && rm #{execution_file}" if options[:copy_before_exec]
    end

    # Copies file from local 'origin' to remote 'destination'
    def remote_copy(origin, destination)
      Log.info "#@deployment_name: Uploading '#{origin}' to #{destination}..."

      connection.scp.upload!(origin, destination)
    end

    # Changes the permissions of supplied path with supplied modification string.
    def chmod(permissions, file_or_folder_path)
      Log.info "#@deployment_name: Setting permissions for #{file_or_folder_path} to #{permissions}"

      execute "chmod #{permissions} #{file_or_folder_path}"
    end

    # Executes OSSEC server logger
    # @param bin_path [String] path to OSSEC server log executable.
    def execute_logger(bin_path)
      Log.info "#{@deployment_name}: Verifying existance of OSSEC collector executable"

      unless path_exists?(bin_path)
        raise Exceptions::ServerLoggerExecutableMissing, "OSSEC collector executable doesn't exist in #{@deployment_name}"
      end

      Log.info "#{@deployment_name}: Executing OSSEC collector"
      execute bin_path
    end

    private

    # Untested
    def execute(command)
      Log.debug command
      out, err, exit_code = ssh_exec! connection, "source /etc/profile && #{command}"
      if exit_code != 0
        Log.error err.strip
        raise Exceptions::DeployerError, "Execution of shell command '#{command}' returned non-zero exit-code. Check logs for more information."
      else
        Log.debug(out.strip) unless out.empty?
        out.strip
      end
    end

    # This method was obtained the source mentioned below, and is mostly unchanged.
    # http://stackoverflow.com/questions/3386233/how-to-get-exit-status-with-rubys-netssh-library
    #
    # Untested method
    def ssh_exec!(ssh, command)
      stdout_data = ''
      stderr_data = ''
      exit_code = nil
      ssh.open_channel do |channel|
        channel.exec(command) do |chann, success|
          unless success
            raise Exceptions::DeployerError, "ssh_exec! method failed! Couldn't execute command (ssh.channel.exec)."
          end

          channel.on_data do |ch, data|
            stdout_data += data
          end

          channel.on_extended_data do |ch, type, data|
            stderr_data += data
          end

          channel.on_request('exit-status') do |ch, data|
            exit_code = data.read_long
          end
        end
      end

      ssh.loop
      [stdout_data, stderr_data, exit_code]
    end
  end
end
