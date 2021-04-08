class DropScheduleLogTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :schedule_logs
  end
end
