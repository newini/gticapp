class AddPanelistFlgToRelationship < ActiveRecord::Migration[4.2]
  def change
    add_column :relationships, :panelist_flg, :boolean
    add_index :relationships, :panelist_flg
  end
end
