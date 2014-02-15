class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :last_name
      t.string :first_name_kana
      t.string :last_name_kana
      t.string :email
      t.string :affiliation
      t.string :title
      t.string :note
      t.string :facebook_name
      t.string :job
      t.boolean :black_list_flg, default: false
      t.timestamps
    end
    add_index :members, :last_name_kana
    add_index :members, :email
    add_index :members, :affiliation
    add_index :members, :black_list_flg
    add_index :members, :facebook_name
  end
end
