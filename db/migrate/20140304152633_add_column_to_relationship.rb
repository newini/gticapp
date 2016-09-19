class AddColumnToRelationship < ActiveRecord::Migration
  def change
    add_column :relationships, :guest_flg, :boolean
    add_index :relationships, :guest_flg
  end
end
