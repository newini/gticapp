class Member < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  has_many :relationships, foreign_key: "member_id", dependent: :destroy
  has_many :events, through: :relationships, source: :event
  has_many :registed_events, -> { where "status = 2"}, through: :relationships, source: :event 
  has_many :participated_events, -> { where "status = 3"}, through: :relationships, source: :event 
#紹介者同士のrelation
  has_many :member_relationships, foreign_key: "introduced_id", dependent: :destroy
  has_many :introducer, through: :member_relationships, source: :introducer
  has_many :reverse_member_relationships, foreign_key: "introducer_id", dependent: :destroy, class_name: "MemberRelationship"
  has_many :introduced_members, through: :reverse_member_relationships, source: :introduced

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      member = Member.where(fb_user_id: row["fb_user_id"]).find_by_fb_user_id(row["fb_user_id"])
      parameters = ActionController::Parameters.new(row.to_hash)
      member.update(parameters.permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :fb_name, :affiliation, :email))
      member.save
      if member.introducer.where(last_name: row["introducer_last_name"]).find_by_first_name(row["introducer_first_name"]).blank?
        introducer = Member.where(last_name: row["introducer_last_name"]).find_by_first_name(row["introducer_first_name"]) || Member.new
        introducer.update(last_name: row["introducer_last_name"], first_name: row["introducer_first_name"])
        introducer.save!
        member.member_relationships.create(introducer_id: introducer.id)
      end
    end
  end
  def participate!(participated_event)
    relationships.create!(participated_id: participated_event.id)
  end
  def cancel!(participated_event)
    relationships.find_by(participated_id: participated_event.id).destroy
  end
  def self.to_csv
    csv_data = CSV.generate do |csv|
      csv << column_names
      all.each do |row|
        csv << row.attributes.values_at(*self.column_names)
      end
    end
  end
end
