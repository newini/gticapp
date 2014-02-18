class Event < ActiveRecord::Base
  validates :name, presence:true, length: { maximum: 50 }
  has_many :relationships, foreign_key: "event_id", dependent: :destroy
  has_many :members, through: :relationships, source: :member
  has_many :waiting_members, -> { where "status = 0"}, through: :relationships, source: :member 
  has_many :invited_members, -> { where "status = 1"}, through: :relationships, source: :member 
  has_many :registed_members, -> { where "status = 2"}, through: :relationships, source: :member 
  has_many :participants, -> { where "status = 3"}, through: :relationships, source: :member 
  has_many :canceled_members, -> {where "status = 4"}, through: :relationships, source: :member 
  has_many :no_show, -> {where "status = 5"}, through: :relationships, source: :member 
  has_many :presenters, -> {where presenter_flg: true}, class_name: "Relationship", through: :relationships, source: :member
  has_many :invitations, dependent: :destroy

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Event.create! row.to_hash
    end
  end
  def self.import_registed_members(file,event_id)
    CSV.foreach(file.path, headers: true) do |row|
      member = Member.where(last_name: row["last_name"]).find_by_first_name(row["first_name"]) || Member.new
      if member.last_name.blank?
        parameters = ActionController::Parameters.new(row.to_hash)
        member.update(parameters.permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :facebook_name, :affiliation, :title, :note, :email))
        member.save!
      end
      relationship = Relationship.where(event_id: event_id).find_by_member_id(member.id) || Relationship.new
      relationship.update(member_id: member.id, event_id: event_id, status: 2 )
      relationship.save!
    end
  end


  def self.import_participants(file,event_id)
    CSV.foreach(file.path, headers: true) do |row|
      member = Member.where(last_name: row["last_name"]).find_by_first_name(row["first_name"]) || Member.new
      if member.last_name.blank?
        parameters = ActionController::Parameters.new(row.to_hash)
        member.update(parameters.permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :facebook_name, :affiliation, :title, :note, :email))
        member.save!
      end
      relationship = Relationship.where(event_id: event_id).find_by_member_id(member.id) || Relationship.new
      relationship.update(member_id: member.id, event_id: event_id, status: 3 )
      relationship.save!
      if member.introducer.where(last_name: row["introducer_last_name"]).find_by_first_name(row["introducer_first_name"]).blank?
        introducer = Member.where(last_name: row["introducer_last_name"]).find_by_first_name(row["introducer_first_name"]) || Member.new
        introducer.update(last_name: row["introducer_last_name"], first_name: row["introducer_first_name"])
        introducer.save!
        member.member_relationships.create(introducer_id: introducer.id)
      end
 
    end
  end

end
