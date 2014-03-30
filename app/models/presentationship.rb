class Presentationship < ActiveRecord::Base
  belongs_to :member, class_name: "Member"
  belongs_to :event, class_name: "Event"
  belongs_to :presentation, class_name: "Presentation", primary_key: :id
end
