class AddUserInfoToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name_alphabet, :string
    add_column :users, :first_name_alphabet, :string
    add_column :users, :age, :integer
    add_column :users, :gender, :integer
    add_column :users, :birthday, :datetime
    add_column :users, :category_id, :integer
    add_column :users, :affiliation, :string
    add_column :users, :title, :string
  end
end
