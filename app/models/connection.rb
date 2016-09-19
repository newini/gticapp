class Connection < ActiveRecord::Base
  belongs_to :invited_member, class_name: "Member"
  belongs_to :invited_event, class_name: "Event"
end
