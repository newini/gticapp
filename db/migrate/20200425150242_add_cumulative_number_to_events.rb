class AddCumulativeNumberToEvents < ActiveRecord::Migration
  def change
    add_column :events, :cumulative_number, :integer
  end
end
