require_relative '../../lib/union/trello'

TRELLO_API = Union::Trello::API.new ENV['TRELLO_API_KEY'], ENV['TRELLO_API_TOKEN']
