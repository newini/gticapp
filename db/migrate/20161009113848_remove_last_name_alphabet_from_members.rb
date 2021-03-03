class RemoveLastNameAlphabetFromMembers < ActiveRecord::Migration[4.2]
  def change
    remove_column :members, :last_name_alphabet, :string
    remove_column :members, :first_name_alphabet, :string
  end
end
