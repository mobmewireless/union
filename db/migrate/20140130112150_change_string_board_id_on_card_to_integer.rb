class ChangeStringBoardIdOnCardToInteger < ActiveRecord::Migration
  def change
    change_column :cards, :board_id, :integer
  end
end
