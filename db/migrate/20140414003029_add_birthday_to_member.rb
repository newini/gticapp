class AddBirthdayToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :birthday, :datetime
    add_index :members, :birthday
  end
end
