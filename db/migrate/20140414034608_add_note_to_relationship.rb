class AddNoteToRelationship < ActiveRecord::Migration[4.2]
  def change
    add_column :relationships, :note, :string
    add_index :relationships, :note
  end
end
