class Presentation < ActiveRecord::Base
  has_many :presentationships, foreign_key: "presentation_id", dependent: :destroy
  has_many :presenters, through: :presentationships, source: :member

  #scope
  scope :search_presentation, ->(keyword) { where("title like ? OR abstract like ?", "%#{keyword}%", "%#{keyword}%" ) }

end
