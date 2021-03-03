class CreatePresentationships < ActiveRecord::Migration[4.2]
  def change
    create_table :presentationships do |t|
      t.integer :member_id
      t.integer :event_id
      t.integer :presentation_id

      t.timestamps
    end
    add_index :presentationships, :member_id
    add_index :presentationships, :event_id
    add_index :presentationships, :presentation_id
    add_index :presentationships, [:member_id, :event_id, :presentation_id], unique: true, name: "presentationship_index"
  end
end
