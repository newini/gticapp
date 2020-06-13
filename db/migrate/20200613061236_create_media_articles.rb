class CreateMediaArticles < ActiveRecord::Migration
  def change
    create_table :media_articles do |t|
      t.datetime :datetime
      t.string :media
      t.string :url
      t.string :title
      t.string :content

      t.timestamps null: false
    end
  end
end
