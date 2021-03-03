class AddAgeToMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :age, :integer
  end
end
