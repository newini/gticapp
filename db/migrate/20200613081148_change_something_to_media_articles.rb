class ChangeSomethingToMediaArticles < ActiveRecord::Migration[4.2]
  def change
    remove_column :media_articles, :datetime, :string
    add_column :media_articles, :date, :datetime
    remove_column :media_articles, :content, :string
    add_column :media_articles, :member_id, :integer
  end
end
