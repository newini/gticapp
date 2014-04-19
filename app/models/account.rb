class Account < ActiveRecord::Base
  has_many :registers, foreign_key: "account_iD", dependent: :destroy
  has_many :events, through: :registers, source: :event
end
