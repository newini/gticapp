class AddPanelistFlgToRelationship < ActiveRecord::Migration
  def change
    add_column :relationships, :panelist_flg, :boolean
    add_index :relationships, :panelist_flg
  end
end
