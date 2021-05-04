class ChangeOnMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :profile_picture_data, :binary
    add_column :members, :profile_picture_name, :string
    add_column :members, :profile_picture_mime_type, :string
  end
end
