set :output, '/var/log/trello_reports.log'

every 1.day, at: '18:30 PM' do
  runner 'Union::Trello::Tasks.archive_done_cards'
  runner 'Report.burndown!'
end
