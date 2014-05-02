module Union::Trello
  class Tasks
    class << self
      def logger
        @logger ||= begin
          if defined?(Rails)
            Rails.logger
          else
            Logger.new STDOUT
          end
        end
      end

      def archive_done_cards
        Board.subscribed.each do |board|
          TRELLO_API.done_cards(board).each do |trello_card|
            last_activity = if trello_card['actions'].first.nil?
              Time.parse trello_card['dateLastActivity']
            else
              Time.parse trello_card['actions'].first['date']
            end

            if last_activity < 7.days.ago
              logger.info "Archiving done trello card with ID #{trello_card['id']}..."
              TRELLO_API.archive trello_card['id']
            else
              logger.info "Trello card #{trello_card['id']} has been inactive in Done list for less than 7 days. Ignoring."
            end
          end
        end

        logger.flush
      end
    end
  end
end