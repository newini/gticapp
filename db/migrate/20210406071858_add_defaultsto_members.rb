class AddDefaultstoMembers < ActiveRecord::Migration[6.1]
  def change
    change_column :members, :black_list_flg, :boolean, default: false
    change_column :members, :gtic_flg, :boolean, default: false
  end
end
