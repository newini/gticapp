class CreateEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :events do |t|
      t.string :name
      t.string :fb_event_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :place_id
      t.integer :fee

      t.timestamps
    end
    add_index :events, :name
    add_index :events, :start_time
    add_index :events, :place_id
  end
end
