class AddFilePathToMediaArticles < ActiveRecord::Migration[4.2]
  def change
    add_column :media_articles, :file_path, :string
  end
end
