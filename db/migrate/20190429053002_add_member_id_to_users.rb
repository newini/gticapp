class AddMemberIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :member_id, :integer
  end
end
