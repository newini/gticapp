class ChangesOnStaffs < ActiveRecord::Migration[6.1]
  def change
    remove_column :staffs, :provider, :string
    remove_column :staffs, :uid, :string
  end
end
