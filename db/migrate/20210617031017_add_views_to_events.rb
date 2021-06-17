class AddViewsToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :views, :integer, default: 0
  end
end
