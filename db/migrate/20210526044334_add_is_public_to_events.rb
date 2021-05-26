class AddIsPublicToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :is_public, :boolean, :default => false
  end
end
