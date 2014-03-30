class RemovePresentationIdFromRelationship < ActiveRecord::Migration
  def change
    remove_column :relationships, :presentation_id, :string
  end
end
