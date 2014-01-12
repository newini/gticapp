class AddUrlToEvent < ActiveRecord::Migration
  def change
    add_column :events, :url, :string
    add_index :events, :url
  end
end
