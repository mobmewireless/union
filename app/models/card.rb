class Card < ActiveRecord::Base
  attr_accessible :trello_id

  has_many :card_tags, dependent: :destroy
  has_many :servers, through: :card_tags, source: :target, source_type: 'Server'
  has_many :projects, through: :card_tags, source: :target, source_type: 'Project'
  belongs_to :board

  STATUS_NEW = :new
  STATUS_WIP = :wip
  STATUS_DONE = :done
  STATUS_UNKNOWN = :unknown

  LABEL_BUSINESS = 'green'
  LABEL_INTERNAL = 'yellow'
  LABEL_CHANGE = 'orange'
  LABEL_UNPLANNED = 'red'

  serialize :data, ActiveSupport::HashWithIndifferentAccess

  # Returns status of card as one of the STATUS_* constants.
  def status
    case trello_list_id
      when board.new_list_id
        Card::STATUS_NEW
      when board.wip_list_id
        Card::STATUS_WIP
      when board.done_list_id
        Card::STATUS_DONE
      else
        Card::STATUS_UNKNOWN
    end
  end

  # TODO: Spec Card#creator_name
  def creator_name
    data[:creator][:fullName] if data.include? :creator
  end

  # TODO: Spec Card#creator_url
  def creator_url
    trello_user_url(data[:creator][:username]) if data.include? :creator
  end

  # TODO: Spec Card#trello_user_url
  def trello_user_url(username)
    "https://trello.com/#{username}"
  end

  # TODO: Spec Card#trello_card_url
  def trello_card_url(short_link)
    "https://trello.com/c/#{short_link}"
  end

  # TODO: Spec Card#name
  def name
    data[:card][:name]
  end

  # TODO: Spec Card#url
  def url
    trello_card_url(data[:card][:shortLink])
  end

  # TODO: Spec Card#assigned_members
  def assigned_members
    return {} if data[:members].nil?

    data[:members].values.inject({}) do |assigned_members, member|
      assigned_members[member[:fullName]] = trello_user_url(member[:username])
      assigned_members
    end
  end

  def scan_and_add_tags(text)
    cached_tags = Union::Trello::CachedCardTags.tags

    extract_fqns(text).each do |fqn|
      if cached_tags.include? fqn
        if cached_tags[fqn].include? :project_id
          project = Project.find(cached_tags[fqn][:project_id])

          if project
            projects << project unless projects.include? project
          end
        end

        if cached_tags[fqn].include? :server_id
          server = Server.find(cached_tags[fqn][:server_id])

          if server
            servers << server unless servers.include? server
          end
        end
      end
    end
  end

  # Returns cycle time in seconds - time taken to complete card since work began.
  #
  # @return [Float] cycle time in seconds
  def cycle_time
    if completed_at && started_at
      completed_at - started_at
    else
      0.0
    end
  end

  # Returns lead time in seconds - time taken to complete card since its creation.
  #
  # @return [Float] lead time in seconds
  def lead_time
    if completed_at
      completed_at - created_at
    else
      0.0
    end
  end

  private

  def extract_fqns(text)
    (text.scan(/([0-9a-zA-Z-]+)/).map do |result|
      result[0] if result[0].include?('-')
    end - [nil]).uniq
  end
end
