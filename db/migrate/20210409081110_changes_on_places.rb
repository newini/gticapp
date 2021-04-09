class ChangesOnPlaces < ActiveRecord::Migration[6.1]
  def change
    remove_index :places, :name

    add_column :places, :city, :string
    add_column :places, :nearest_station, :string
    add_column :places, :how_to_go, :string
  end
end
