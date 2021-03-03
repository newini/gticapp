class AddActiveFlgToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :active_flg, :boolean
  end
end
