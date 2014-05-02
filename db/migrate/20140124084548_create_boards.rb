class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.string :trello_board_id, null: false
      t.string :new_list_id
      t.string :wip_list_id
      t.string :done_list_id
      t.string :name, null: false
      t.string :short_url, null: false
      t.string :trello_webhook_id

      t.timestamps
    end

    add_index :boards, :trello_board_id, unique: true
  end
end
