class AddAdminToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :admin, :boolean
    add_column :users, :language, :integer
  end
end
