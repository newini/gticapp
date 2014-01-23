class AddColumnToMember < ActiveRecord::Migration
  def change
    add_column :members, :black_list_flg, :boolean, default: false
    add_index :members, :black_list_flg
  end
end
