class MediaArticle < ActiveRecord::Base
  belongs_to :member

  #scope
  scope :search_media_article, ->(keyword) {
    where("media like ? OR title like ? OR description like ?",
          "%#{keyword}%", "%#{keyword}%", "%#{keyword}%"
    )
  }
end
