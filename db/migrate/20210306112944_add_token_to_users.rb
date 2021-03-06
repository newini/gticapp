class AddTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :access_token, :string
  end
end
