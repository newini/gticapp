class AddProviderToMembers < ActiveRecord::Migration[6.1]
  def change
    remove_index :members, :fb_user_id
    remove_index :members, :email

    add_index :members, :first_name
    add_index :members, :first_name_alphabet

    add_column :members, :provider, :string

    rename_column :members, :fb_user_id, :uid
    rename_column :members, :fb_name, :name
  end
end
