module Union
  module ServerLogger
  end
end

require 'enat'
require 'logger'
require 'active_support/hash_with_indifferent_access'

require_relative 'server_connection'
require_relative 'server_logger/collector'
