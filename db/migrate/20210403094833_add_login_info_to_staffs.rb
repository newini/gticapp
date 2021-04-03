class AddLoginInfoToStaffs < ActiveRecord::Migration[6.1]
  def change
    rename_column :staffs, :user_id, :uid
  end
end
