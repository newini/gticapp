class Relationship < ActiveRecord::Base
  belongs_to :participant, class_name: "Member"
  belongs_to :participated, class_name: "Event"
end
