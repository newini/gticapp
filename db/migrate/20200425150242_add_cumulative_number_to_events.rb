class AddCumulativeNumberToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :cumulative_number, :integer
  end
end
