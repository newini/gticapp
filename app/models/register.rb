class Register < ActiveRecord::Base
  belongs_to :event
  belongs_to :account
  validates :amount, presence:true

end
