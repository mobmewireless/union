class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :trello_id
      t.string :trello_list_id
      t.string :type
      t.integer :time_spent
      t.boolean :archived
      t.text :data
      t.datetime :due
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :cards, %w(trello_list_id archived)
    add_index :cards, %w(type archived)
    add_index :cards, :trello_id, unique: true
  end
end
