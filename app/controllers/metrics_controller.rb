class MetricsController < ApplicationController# TODO: Spec MetricsController#board
  def board
    @board = Board.find params[:board_id]
    @cards = @board.cards_with_status(Card::STATUS_DONE).where(archived: false).order('updated_at DESC').limit(100)
  end

  def burndown
    #@burndown = [
    #  { name: 'New', data: {Time.now => 5, Time.now - 1.day => 6, Time.now - 2.days => 9, Time.now - 3.days => 4 } },
    #  { name: 'WIP', data: {Time.now => 3, Time.now - 1.day => 2, Time.now - 2.days => 3, Time.now - 3.days => 5 } }
    #]
    board = Board.find(params[:board_id])
    @burndown = Report.burndown_report(board)
  end
end
