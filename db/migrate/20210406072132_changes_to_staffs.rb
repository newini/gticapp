class ChangesToStaffs < ActiveRecord::Migration[6.1]
  def change
    change_column :staffs, :admin, :boolean, default: false
    change_column :staffs, :active_flg, :boolean, default: false

    rename_column :staffs, :admin, :is_admin
    rename_column :staffs, :active_flg, :is_active
  end
end
