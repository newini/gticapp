class Event < ActiveRecord::Base
  validates :name, presence:true, length: { maximum: 50 }
  validates :date, presence:true
  has_many :relationships, foreign_key: "participated_id", dependent: :destroy
  has_many :participants, through: :relationships, source: :participant
  has_many :connections, foreign_key: "invited_event_id", dependent: :destroy
  has_many :invited_members, through: :connections, source: :invited_member
  has_many :invitations, dependent: :destroy

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Event.create! row.to_hash
    end
  end
  def self.import_participants(file,event_id)
    CSV.foreach(file.path, headers: true) do |row|
      member = Member.find_by_name(row["name"]) || Member.new
      if member.name.blank?
        parameters = ActionController::Parameters.new(row.to_hash)
        member.update(parameters.permit(:name, :name_kana, :facebook_name, :affiliation, :email))
        member.save!
      end
      relationship = Relationship.where(participated_id: event_id).find_by_participant_id(member.id) || Relationship.new
      relationship.update(participant_id: member.id, participated_id: event_id)
      relationship.save!
    end
  end

end
