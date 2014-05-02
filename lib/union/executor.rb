require_relative '../exceptions'
require_relative 'log'

module Union
  class Executor
    # Executes a shell command.
    # Untested
    def self.execute(command)
      Log.debug command

      output = `#{command} 2>&1`.strip

      if $?.success?
        Log.debug(output) unless output.empty?
        output
      else
        Log.error "Execution of shell command '#{command}' returned non-zero exit-code. Details follow."
        Log.error output
        raise Exceptions::DeployerError, "Execution of shell command '#{command}' returned non-zero exit-code. Check logs for more information."
      end
    end
  end
end
