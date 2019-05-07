class AddActiveFlgToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active_flg, :boolean
  end
end
