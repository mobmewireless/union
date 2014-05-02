class Server < ActiveRecord::Base
  attr_accessible :hostname, :port, :logging, :login_user, :manually_created

  has_many :deployments
  has_many :projects, through: :deployments

  has_many :card_tags, as: :target
  has_many :cards, through: :card_tags

  has_many :server_logs

  TIME_UNIT_SECOND = :second
  TIME_UNIT_MINUTE = :minute
  TIME_UNIT_HOUR = :hour
  TIME_UNIT_DAY = :day
  TIME_UNIT_WEEK = :week

  validates_uniqueness_of :hostname
  validate :validate_logging

  class << self
    # Returns all servers which are not associated with any project
    #
    # @return [Array<Server>] array of orphaned servers
    def orphaned_servers
      all.select { |server| server.projects.empty? }
    end

    # Returns server host-names and ID-s, suitable for caching.
    #
    # @return [Hash] host-name to ID mapping
    def card_tags
      select('id, hostname').inject({}) do |hash, s|
        hash[s.hostname] = { server_id: s.id }
        hash
      end.with_indifferent_access
    end
  end

  # Returns absolute and moving-average values of time to repair ()complete unplanned cards) since supplied time.
  #
  # @param [Time] since_time Least date from which MTTRs are to be calculated.
  # @option [Symbol] :unit (:second) Time unit in which results are to be returned.
  # @return [Hash] Hash of moving averages of TTR since supplied time.
  def time_to_repair(since_time, unit: :second)
    total_repair_time = 0
    total_repairs = 0
    ttr = { point_values: {}, moving_averages: {} }

    # Unplanned cards created after since_time, in order of creation.
    cards.where('cards.created_at > ?', since_time).where('cards.label = ?', Card::LABEL_UNPLANNED).order('cards.created_at DESC').map do |unplanned_card|
      lead_time = unplanned_card.lead_time

      if lead_time > 0
        total_repairs += 1
        total_repair_time += time_in_unit(lead_time, unit)

        ttr[:point_values][unplanned_card.created_at] = time_in_unit(lead_time, unit)
        ttr[:moving_averages][unplanned_card.created_at] = total_repair_time / total_repairs
      end
    end

    ttr
  end

  # Returns absolute and moving-average values of time between failures (creation of unplanned card and completion of
  # last unplanned card) since supplied time.
  #
  # @param [Time] since_time Least date from which MTBFs are to be calculated
  # @option [Symbol] :unit (:second) Time unit in which results are to be returned.
  # @return [Hash] Hash of moving averages of TBF since supplied time
  def time_between_failures(since_time, unit: :second)
    total_uptime = 0
    total_failures = 0
    tbf = { point_values: {}, moving_averages: {} }

    # Unplanned cards created after since_time, in order of creation.
    unplanned_cards = cards.where('cards.created_at > ?', since_time).where('cards.label = ?', Card::LABEL_UNPLANNED).order('cards.created_at DESC')

    unplanned_cards.each_with_index do |unplanned_card, index|
      previous_unplanned_card = unplanned_cards[index + 1]

      if previous_unplanned_card && previous_unplanned_card.completed_at
        uptime = unplanned_card.created_at - previous_unplanned_card.completed_at
        total_failures += 1
        total_uptime += time_in_unit(uptime, unit)

        tbf[:point_values][unplanned_card.created_at] = time_in_unit(uptime, unit)
        tbf[:moving_averages][unplanned_card.created_at] = total_uptime / total_failures
      end
    end

    tbf
  end

  # Returns hash containing timestamp and details from ServerLog and Card
  #
  # @param [Time] since_time
  # @return [Hash] Hash of timstamps to y_position and annotation
  def logs_and_cards_with_timestamp(since_time)
    required_logs = server_logs.where('server_logs.created_at > ?', since_time).order('server_logs.created_at DESC')
    required_cards = cards.where('cards.created_at > ?', since_time).order('cards.created_at DESC')

    formatted_logs_info = required_logs.inject({}) do |specific_log_info, required_log|
      specific_log_info[required_log.timestamp] = required_log.log.join(',')
      specific_log_info
    end if required_logs.count > 0

    formatted_cards_info = required_cards.inject({}) do |specific_card_info, required_card|
      specific_card_info[required_card.created_at.to_i.to_s] = "<a href=#{required_card.url}>Trello URL</a>"
      specific_card_info
    end if required_cards.count > 0

    { logs: formatted_logs_info, cards: formatted_cards_info }
  end

  private

  def time_in_unit(time, unit)
    case unit
      when :minute
        time / 60.0
      when :hour
        time / 3600.0
      when :day
        time / 86400.0
      when :week
        time / 604800.0
      else
        time
    end
  end

  def validate_logging
    if logging
      unless login_user.present?
        errors.add(:base, 'Login user must be present.')
      end

      unless port.present?
        errors.add(:base, 'Port must be present.')
      end
    end
  end
end
