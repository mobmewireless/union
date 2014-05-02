json.array! @burndown do |burndown|
  json.name burndown[0] == :new ? 'New' : 'WIP'
  json.data burndown[1]
end
