class Broadcast < ActiveRecord::Base
  has_many :broadcast_members, dependent: :destroy
  has_many :members, through: :broadcast_members
end
