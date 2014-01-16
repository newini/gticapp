class AddColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :start_time, :datetime
    add_column :events, :place, :string
    add_column :events, :fee, :integer
  end
end
