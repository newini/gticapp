class ChangesOnUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :member_id, :integer
  end
end
