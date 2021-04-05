class BroadcastMember < ActiveRecord::Base
  belongs_to :broadcast
  belongs_to :member
end
