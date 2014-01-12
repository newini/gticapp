class AddPresenterFlgToRelationship < ActiveRecord::Migration
  def change
    add_column :relationships, :presenter_flg, :boolean, :default => false
    add_index :relationships, :presenter_flg
  end
end
