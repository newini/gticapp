class RemoveFilePathFromMediaArticles < ActiveRecord::Migration[6.1]
  def change
    remove_column :media_articles, :file_path, :string
  end
end
