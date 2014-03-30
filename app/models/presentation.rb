class Presentation < ActiveRecord::Base
  has_many :presentationships, foreign_key: "presentation_id", dependent: :destroy
  has_many :presenters, through: :presentationships, source: :member
end
