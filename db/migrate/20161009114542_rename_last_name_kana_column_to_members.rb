class RenameLastNameKanaColumnToMembers < ActiveRecord::Migration[4.2]
  def change
    rename_column :members, :last_name_kana, :last_name_alphabet
    rename_column :members, :first_name_kana, :first_name_alphabet
  end
end
