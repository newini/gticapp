class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :password_digest
      t.string :remember_token
      t.string :provider
      t.string :uid
      t.string :image_url
      t.string :access_token


      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :remember_token
    add_index :users, :provider
    add_index :users, :uid, unique: true
    add_index :users, :access_token
  end
end
