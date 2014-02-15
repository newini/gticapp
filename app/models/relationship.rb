class Relationship < ActiveRecord::Base
  belongs_to :member, class_name: "Member"
  belongs_to :event, class_name: "Event"
end
