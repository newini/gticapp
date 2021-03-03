class AddPresentationIdToRelationship < ActiveRecord::Migration[4.2]
  def change
    add_column :relationships, :presentation_id, :integer
    add_index :relationships, :presentation_id
  end
end
