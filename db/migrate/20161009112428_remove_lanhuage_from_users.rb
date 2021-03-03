class RemoveLanhuageFromUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :language, :integer
  end
end
