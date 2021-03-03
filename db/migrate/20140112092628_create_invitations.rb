class CreateInvitations < ActiveRecord::Migration[4.2]
  def change
    create_table :invitations do |t|
      t.integer :event_id
      t.string :title
      t.text :greeting
      t.text :content

      t.timestamps
    end
    add_index :invitations, :event_id
  end
end
