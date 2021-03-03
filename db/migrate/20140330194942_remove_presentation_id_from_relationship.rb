class RemovePresentationIdFromRelationship < ActiveRecord::Migration[4.2]
  def change
    remove_column :relationships, :presentation_id, :string
  end
end
