class ChangesOnEvents < ActiveRecord::Migration[6.1]
  def change
    remove_column :events, :bkg_filename, :string
    remove_column :events, :bkg_mime_type, :string
    remove_column :events, :bkg_data, :binary

    remove_index :events, :name

    add_column :events, :bkg_image_id, :integer
  end
end
