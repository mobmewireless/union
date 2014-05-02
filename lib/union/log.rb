# Standard
require 'fileutils'

# Enable STDOUT syncing so that logs appear in log files as soon as they're emitted.
$stdout.sync = true

# Gems
require 'log4r'

# Local
require_relative 'config'

module Union
  class Log
    class << self
      attr_writer :logger
      include Log4r

      # Let's allow dev-s to access the logger's instance methods directly. It reads better this way.
      %w(debug info warn error fatal).each do |meth|
        define_method(meth) { |message| logger.send(meth.to_sym, message) }
      end

      def reset_everything!
        @logger = nil
      end

      # Returns an STDOUT logger
      def logger
        @logger ||= begin
          raise "log_level and / or job_id hasn't been set!" unless (Config.log_level or Config.job.id)

          # Create a logger (log4r).
          log = Logger.new 'union'

          # Create formatter.
          log_pattern_formatter = PatternFormatter.new pattern: "%d [%l] (#{Config.job.id}) %m"

          # Create the log directory if it doesn't exist.
          year_and_month = Time.now.in_time_zone('Asia/Calcutta').strftime('%Y_%m')
          log_directory = "#{Config.log_path}/#{year_and_month}"
          FileUtils.mkdir_p(log_directory) unless File.exist?(log_directory)

          # Create outputters.
          file_outputter = FileOutputter.new('union_file_log', filename: "#{log_directory}/job_#{Config.job.id}.log")
          stdout_outputter = StdoutOutputter.new('union_stdout')

          # Set formatters for outputters.
          file_outputter.formatter = log_pattern_formatter
          stdout_outputter.formatter = log_pattern_formatter

          # Set outputters.
          log.outputters = stdout_outputter, file_outputter

          # Set log level
          log.level = Config.log_level

          # Now return the customized logger.
          log
        end
      end
    end
  end
end