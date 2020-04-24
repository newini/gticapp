class Invitation < ActiveRecord::Base
  #belongs_to :event
  #has_many :all_members, -> {where "member_id = 1884"}, source: :member # test
  #has_many :invited_members, -> {where "status = 1"}, through: :relationships, source: :member
end
