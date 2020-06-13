class AddFilePathToMediaArticles < ActiveRecord::Migration
  def change
    add_column :media_articles, :file_path, :string
  end
end
