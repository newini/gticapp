class AddModeratorFlgToRelationship < ActiveRecord::Migration[4.2]
  def change
    add_column :relationships, :moderator_flg, :boolean
    add_index :relationships, :moderator_flg
  end
end
