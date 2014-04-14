class AddBirthdayToMember < ActiveRecord::Migration
  def change
    add_column :members, :birthday, :datetime
    add_index :members, :birthday
  end
end
