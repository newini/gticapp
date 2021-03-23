class AddMediaFileToMedia < ActiveRecord::Migration[6.1]
  def change
    add_column :media_articles, :file_data, :binary
    add_column :media_articles, :file_name, :string
    add_column :media_articles, :file_mime_type, :string
  end
end
