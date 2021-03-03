class RenamePresenterFlgColumnToRelationships < ActiveRecord::Migration[4.2]
  def change
    rename_column :relationships, :presenter_flg, :presentation_role
    change_column :relationships, :presentation_role, :integer
  end
end
