class Board < ActiveRecord::Base
  has_many :cards, dependent: :destroy
  has_many :reports, as: :owner

  scope :subscribed, -> { where 'trello_webhook_id IS NOT NULL' }

  # Contact Trello API and add missing boards to database.
  def self.refresh!
    TRELLO_API.boards.each do |trello_board|
      board = find_or_initialize_by(trello_board_id: trello_board['id'])
      board.name = trello_board['name']
      board.short_url = trello_board['shortUrl']
      board.save
    end
  end

  def cards_with_status(*required_status, exclude_discarded: false)
    required_trello_list_ids = required_status.map do |required_status|
      case required_status
        when Card::STATUS_NEW
          new_list_id
        when Card::STATUS_WIP
          wip_list_id
        when Card::STATUS_DONE
          done_list_id
        else
          raise StandardError, 'required_status for board.cards_with_status must be one of Card::STATUS_NEW, Card::STATUS_WIP, or Card::STATUS_DONE'
      end
    end

    required_cards = cards.where(trello_list_id: required_trello_list_ids)
    exclude_discarded ? required_cards.where(deleted: [false, nil], archived: [false, nil]) : required_cards
  end
end
