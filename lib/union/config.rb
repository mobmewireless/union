module Union
  # Configuration to be shared between components.
  class Config
    class << self
      attr_writer :cache_path
      attr_writer :log_path
      attr_accessor :job
      attr_accessor :log_level

      def reset_everything!
        @project = nil
        @deployment = nil
        @cache_path = nil
        @log_path = nil
      end

      def root_path
        ENV['UNION_ROOT']
      end

      def project
        @project ||= job.project
      end

      def deployment
        @deployment ||= job.deployment
      end

      def project_name
        project.project_name
      end

      def branch
        project.branch
      end

      def git_url
        project.git_url
      end

      def deployment_name
        deployment.deployment_name
      end

      def host
        deployment.server.hostname
      end

      def cache_path
        @cache_path ||= (root_path + "/cache")
      end

      def log_path
        @log_path ||= (root_path + "/log/jobs")
      end
    end
  end
end