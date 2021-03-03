class AddNoteToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :note, :string
  end
end
