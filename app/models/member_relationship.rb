class MemberRelationship < ActiveRecord::Base
  belongs_to :introducer, class_name: "Member"
  belongs_to :introduced, class_name: "Member"
end
