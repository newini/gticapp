class RenameUsersToStaffs < ActiveRecord::Migration[6.1]
  def self.up
    rename_table :users, :staffs
  end

  def self.down
    rename_table :staffs, :users
  end
end
