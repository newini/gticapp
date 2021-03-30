class RemoveStaffLoginInfoFromStaffs < ActiveRecord::Migration[6.1]
  def change
    remove_column :staffs, :name, :string
    remove_column :staffs, :email, :string
    remove_column :staffs, :password, :string
    remove_column :staffs, :password_digest, :string
    remove_column :staffs, :remember_token, :string
    remove_column :staffs, :image_url, :string
    remove_column :staffs, :access_token, :string

    rename_column :staffs, :uid, :user_id
  end
end
