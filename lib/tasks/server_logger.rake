namespace :server do
  desc 'Pulls OSSEC Logs from servers'
  task logger: :environment do
    Union::ServerLogger::Collector.new.run
  end
end
