class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name
      t.string :name_kana
      t.string :email
      t.string :affiliation

      t.timestamps
    end
    add_index :members, :name_kana
    add_index :members, :email
    add_index :members, :affiliation

  end
end
