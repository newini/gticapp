class AddModeratorFlgToRelationship < ActiveRecord::Migration
  def change
    add_column :relationships, :moderator_flg, :boolean
    add_index :relationships, :moderator_flg
  end
end
