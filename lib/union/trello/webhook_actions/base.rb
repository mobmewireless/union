module Union::Trello::WebhookActions
  class Base
    attr_reader :card

    def initialize(parsed_webhook_action)
      @action = parsed_webhook_action[:action]
    end

    def process
      logger.info "Processing card of type #{type}..."

      # We're not concerned about non-card actions.
      unless data.include?(:card)
        logger.info 'Stopping processing since trello action appears to be unrelated to any card.'
        return
      end

      @card = Card.find_or_initialize_by(trello_id: data[:card][:id])

      if card.new_record?
        card.board = Board.find_by trello_board_id: data[:board][:id]
        card.data = { card: data[:card], creator: member_creator }.with_indifferent_access
        card.scan_and_add_tags data[:card][:name]
      end
    end

    private

    def logger
      if defined? Rails
        Rails.logger
      else
        Logger.new STDOUT
      end
    end

    def post_process
      # If the card's trello_list_id hasn't been set during processing, then let's call the Trello API and find out
      # which list it's on.
      if card.trello_list_id.nil?
        # Get card status by calling the API.
        trello_card = TRELLO_API.card(card.trello_id)
        card.trello_list_id = trello_card['idList']
      end

      # Finally, save the card.
      card.save
    end

    def member_creator
      @action[:memberCreator]
    end

    def data
      @action[:data]
    end

    def type
      @action[:type]
    end
  end
end
