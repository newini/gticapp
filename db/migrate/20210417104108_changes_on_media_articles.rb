class ChangesOnMediaArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :media_articles, :description, :string
    add_column :media_articles, :image_url, :string
  end
end
