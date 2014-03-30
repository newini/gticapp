class AddPresentationIdToRelationship < ActiveRecord::Migration
  def change
    add_column :relationships, :presentation_id, :integer
    add_index :relationships, :presentation_id
  end
end
