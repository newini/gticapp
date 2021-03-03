class RemovePanelistFlgFromRelationships < ActiveRecord::Migration[4.2]
  def change
    remove_column :relationships, :panelist_flg, :boolean
    remove_column :relationships, :moderator_flg, :boolean
  end
end
