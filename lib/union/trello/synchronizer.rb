module Union::Trello
  # This is the meat of the rake task trello:sync. It creates missing cards, or updates existing cards, adding basic
  # details so that cards missed via webhook calls aren't completely unaccounted for.
  #
  # @author Hari Gopal <mail@harigopal.in>
  class Synchronizer
    class << self
      # Performs basic card synchronization for the New, WIP and Done lists.
      def sync!(board_id)
        board = Board.find(board_id)

        [board.new_list_id, board.wip_list_id, board.done_list_id].each do |list_id|
          TRELLO_API.list_cards(list_id).each do |trello_card|
            logger.info "Synchronizing card with ID #{trello_card['id']}..."
            create_or_update trello_card, board
          end
        end
      end

      def logger
        @logger ||= begin
          if defined?(Rails)
            Rails.logger
          else
            Logger.new STDOUT
          end
        end
      end

      # TODO: Set type of card from the label, if any.
      def create_or_update(trello_card, board)
        card = Card.find_or_initialize_by(trello_id: trello_card['id'])

        card.board = board
        card.archived = trello_card['closed']
        card.trello_list_id = trello_card['idList']
        card.due = Time.parse(trello_card['due']) unless trello_card['due'].nil?

        # Card data could be empty, or not, in which case merging is essential.
        card.data ||= {}.with_indifferent_access

        # Add basic card data from creation.
        card_data = { card: trello_card['actions'].first['data']['card'], members: {} }.with_indifferent_access

        # Add member data.
        trello_card['members'].each do |member|
          card_data[:members][member['id']] = member.except('id')
          card_data
        end

        # Add creator data.
        card_data[:creator] = trello_card['actions'].first['memberCreator']

        # Update card name
        card_data[:card][:name] = trello_card['name']

        card.data.merge!(card_data)

        # Scan and add tags from name and description
        card.scan_and_add_tags trello_card['name']
        card.scan_and_add_tags trello_card['desc']

        # Set card label.
        first_label = trello_card['labels'].first
        card.label = first_label['color'] unless first_label.nil?

        # Set card updated_at.
        card.updated_at = Time.parse trello_card['dateLastActivity']

        card.save!
      end
    end
  end
end
