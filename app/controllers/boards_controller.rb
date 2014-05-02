class BoardsController < ApplicationController
  # Trello Board management is only allowed for admins.
  before_filter :require_admin

  def show
    @board = Board.find(params[:id])
    @lists = TRELLO_API.board_lists(@board.trello_board_id).map { |list| [list['name'], list['id']] }
  end

  def update
    board = Board.find params[:id]
    board.update_attributes!(board_params)
    redirect_to board_url(params[:id])
  end

  def destroy
    board = Board.find(params[:id])
    board.destroy
    redirect_to admin_index_url
  end

  # Subscribe to this board by creating Trello webhook.
  # TODO: Quite a few errors are possible when creating new webhooks. Right now, an error from lower levels will float to the surface.
  def subscribe
    board = Board.find params[:id]
    response = TRELLO_API.webhook_subscribe board.trello_board_id
    board.trello_webhook_id = response['id']
    board.save
    redirect_to admin_index_url
  end

  # Delete existing trello webhook on this board.
  def unsubscribe
    board = Board.find params[:id]
    TRELLO_API.webhook_unsubscribe board.trello_webhook_id
    board.trello_webhook_id = nil
    board.save
    redirect_to admin_index_url
  end

  private

  def board_params
    params.require(:board).permit(:new_list_id, :wip_list_id, :done_list_id)
  end
end
