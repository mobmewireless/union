require_relative 'base'

module Union::Trello::WebhookActions
  class MoveCardFromBoard < Base
    def process
      super

      target_board = Board.find_or_initialize_by(trello_board_id: data[:boardTarget][:id])

      if target_board.new_record?
        target_board.name = data[:boardTarget][:name]

        # We'll save a not-so-short URL to save on calling the API to get unavailable 'short' URL.
        target_board.short_url = "https://trello.com/b/#{data[:boardTarget][:id]}"
      end

      target_board.save
      card.board = target_board

      post_process
    end
  end
end
