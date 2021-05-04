class AddFacebookIdToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :facebook_id, :string
  end
end
