require_relative '../exceptions'
require_relative 'config'
require_relative 'executor'
require_relative 'log'

module Union
  class Cache
    class <<self
      def reset_everything!
        @deployment_settings = nil
      end

      # Returns path at which git repository is (to be) cached.
      def repository_path
        File.absolute_path "#{Config.cache_path}/#{cache_repository_name}"
      end

      # Untested
      #
      # We need to keep branches in their own directory to avoid some edge-case errors (related to the shallow clone).
      def cache_repository_name
        case Config.branch.to_s
          when "master"
            Digest::MD5.hexdigest(Config.git_url.to_s)[0..6]
          else
            Digest::MD5.hexdigest(Config.git_url.to_s + Config.branch.to_s)[0..6]
        end
      end

      # Returns the path to the deployment file in cloned repository. Raises error if it doesn't exist.
      def config_file_path
        extension = %w(yaml yml).select { |ext| File.exists?("#{repository_path}/deploy/config.#{ext}") }

        if extension.empty?
          error_message = 'Cloned repository does not contain deploy/config.yaml/yml file.'
          Log.error error_message
          raise Exceptions::DeployerError, error_message
        else
          "#{repository_path}/deploy/config.#{extension.first}"
        end
      end

      # Loads deployment settings from repository's union file into instance variable.
      def deployment_settings
        @deployment_settings ||= YAML.load(File.open(config_file_path, 'r'))
      end

      # Clones repository specified for application.
      def clone_repository
        Executor.execute "git clone --depth 1 #{Config.git_url} #{repository_path} --branch #{Config.branch}"
      end

      # Fetches latest changes from upstream repository into cache.
      def update_repository
        with_git_lock do
          Executor.execute "cd #{repository_path} && git pull"
        end
      end

      # Clones or updates repository, depending on whether it already exists.
      def clone_or_update_repository
        Log.info "#{Config.project_name}: Cloning / updating repository..."
        File.exists?(repository_path) ? update_repository : clone_repository
      end

      # Returns a short revision number for current branch.
      def repository_revision
        File.exists?(repository_path) ? Executor.execute("cd #{repository_path} && git rev-parse --short #{Config.branch}").strip : false
      end

      def with_git_lock
        git_lockfile = File.join(repository_path, '.git', 'union.lock')

        if File.exist? git_lockfile
          Log.warn 'Skipping git-pull operation on the local repository because it looks like another is in process. Waiting for lockfile to disappear...'

          while File.exist? git_lockfile
            sleep 2
          end
        else
          begin
            Executor.execute "touch #{git_lockfile}"
            yield
          ensure
            Executor.execute "rm #{git_lockfile}"
          end
        end
      end
    end
  end
end