class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.integer :num_of_participants
      t.datetime :date

      t.timestamps
    end
    add_index :events, :name
    add_index :events, :num_of_participants
    add_index :events, :date
  end
end
