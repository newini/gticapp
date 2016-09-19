class AddNoteToRelationship < ActiveRecord::Migration
  def change
    add_column :relationships, :note, :string
    add_index :relationships, :note
  end
end
