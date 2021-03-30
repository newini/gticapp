class DropMemberRelationship < ActiveRecord::Migration[6.1]
  def change
    drop_table :member_relationships
  end
end
