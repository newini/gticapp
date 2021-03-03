class AddAlphabetToMember < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :last_name_alphabet, :string
    add_column :members, :first_name_alphabet, :string
    add_index :members, :last_name_alphabet
    add_index :members, :first_name_alphabet
  end
end
