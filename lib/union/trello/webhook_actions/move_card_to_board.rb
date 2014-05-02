require_relative 'base'

module Union::Trello::WebhookActions
  class MoveCardToBoard < Base
    def process
      super

      # Set the board that the card belongs to.
      board = Board.find_by(trello_board_id: data[:board][:id])
      card.trello_list_id = data[:list][:id]
      card.board = board

      post_process
    end
  end
end
