class AddFacebookNameToMember < ActiveRecord::Migration
  def change
    add_column :members, :facebook_name, :string
    add_index :members, :facebook_name
  end
end
