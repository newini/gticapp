class CreateMembers < ActiveRecord::Migration[4.2]
  def change
    create_table :members do |t|
      t.string :last_name
      t.string :first_name
      t.string :last_name_kana
      t.string :first_name_kana
      t.string :email
      t.integer :category_id
      t.string :affiliation
      t.string :title
      t.string :note
      t.string :fb_name
      t.string :fb_user_id
      t.boolean :black_list_flg
      t.boolean :gtic_flg
      t.timestamps
    end
    add_index :members, :last_name
    add_index :members, :last_name_kana
    add_index :members, :email
    add_index :members, :category_id
    add_index :members, :affiliation
    add_index :members, :title
    add_index :members, :fb_name
    add_index :members, :fb_user_id
    add_index :members, :black_list_flg
    add_index :members, :gtic_flg
  end
end
