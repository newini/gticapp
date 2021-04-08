class ChangeToEvnets < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :header_filename, :string
    add_column :events, :header_mime_type, :string
    add_column :events, :header_data, :binary

    add_column :events, :bkg_filename, :string
    add_column :events, :bkg_mime_type, :string
    add_column :events, :bkg_data, :binary
  end
end
