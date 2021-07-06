class AddRomajiToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :romaji, :string
  end
end
