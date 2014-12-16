module Union::ServerLogger
  # Collects OSSEC logs from specified servers.
  class Collector
    def initialize
      # Use default logger
      Union::Log.logger = begin
        Logger.new STDOUT
      end
    end

    # Executes run_and_collect_logs and save_logs in a time loop for servers
    def run
      every 1.hour do
        servers = Server.where(logging: true)
        servers.each do |s|
          logs = run_and_collect_logs(s)
          save_logs(logs, s)
        end
      end
    end

    # Connects to server and runs ossec log collector
    # @param server [Server] Server object.
    # @return [JSON] Logs returned from server or an error message
    def run_and_collect_logs(s)
      name = s.hostname
      server = HashWithIndifferentAccess.new(
          host: s.hostname,
          username: s.login_user,
          port: s.port
      )

      conn = Union::ServerConnection.new(name, server)
      copy_collector(conn)
      conn.execute_logger
    rescue SocketError, Errno::ETIMEDOUT => e
      message = "Couldn't collect logs from #{name} : #{e.message}"
      Union::Log.error message
      {Time.now.to_f => [message]}.to_json
    end

    # Saves logs to database
    # @param logs [JSON] data from server or error.
    # @param server [Server] ActiveRecord server object.
    def save_logs(logs, server)
      logs = JSON.parse(logs)
      logs.each do |time, data|
        server_log = server.server_logs.new(timestamp: time, log: data)
        server_log.save
      end
    end

    private
    def copy_collector(connection)
      unless connection.path_exists?('/tmp/collector.py')
        path = Pathname.new('lib/union/server_logger/collector.py').realpath
        begin
          connection.remote_copy(path, '/tmp/collector.py')
        rescue => e
          Union::Log.error e
        end
      end
    end
  end
end
