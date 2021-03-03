class AddDescriptionToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :description, :string
  end
end
