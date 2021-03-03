class CreatePresentations < ActiveRecord::Migration[4.2]
  def change
    create_table :presentations do |t|
      t.integer :member_id
      t.integer :event_id
      t.string :title
      t.string :abstract
      t.string :note

      t.timestamps
    end
    add_index :presentations, :member_id
    add_index :presentations, :event_id
    add_index :presentations, :title
  end
end
