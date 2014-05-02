namespace :trello do
  desc 'Synchronize Trello cards with local data using the API'
  task :sync, [:board_id] => [:environment] do |t, args|
    Union::Trello::Synchronizer.sync!(args.board_id.to_i)
  end
end
