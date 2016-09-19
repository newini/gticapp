class CreateScheduleLogs < ActiveRecord::Migration
  def change
    create_table :schedule_logs do |t|
      t.integer :event_id
      t.integer :member_id
      t.integer :status

      t.timestamps
    end
    add_index :schedule_logs, :event_id
    add_index :schedule_logs, :member_id
    add_index :schedule_logs, :status
  end
end
