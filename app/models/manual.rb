class Manual < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 4  }
end
