class ServerLog < ActiveRecord::Base
  attr_accessible :timestamp, :log

  belongs_to :server

  validates :timestamp, presence: true, uniqueness: true
  validates_presence_of :log
  serialize :log, JSON
end
