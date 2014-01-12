class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.integer :invited_event_id
      t.integer :invited_member_id

      t.timestamps
    end
    add_index :connections, :invited_event_id
    add_index :connections, :invited_member_id
    add_index :connections, [:invited_event_id, :invited_member_id], unique: true
  end
end
