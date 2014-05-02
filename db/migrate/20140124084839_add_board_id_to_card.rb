class AddBoardIdToCard < ActiveRecord::Migration
  def change
    add_column :cards, :board_id, :string
    add_index :cards, :board_id
  end
end
