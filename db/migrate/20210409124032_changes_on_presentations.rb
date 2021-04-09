class ChangesOnPresentations < ActiveRecord::Migration[6.1]
  def change
    remove_index :presentations, :title

    remove_column :presentations, :note, :string

    add_column :presentations, :start_time, :time
    add_column :presentations, :end_time, :time
  end
end
