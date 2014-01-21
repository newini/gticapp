class Member < ActiveRecord::Base
  validates :name, presence:true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  has_many :relationships, foreign_key: "participant_id", dependent: :destroy
  has_many :participated_events, through: :relationships, source: :participated
  has_many :connections, foreign_key: "invited_member_id", dependent: :destroy
  has_many :invited_events, through: :connections, source: :invited_event
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      member = find_by_name(row["name"])|| new
      parameters = ActionController::Parameters.new(row.to_hash)
      member.update(parameters.permit(:name, :name_kana, :facebook_name, :affiliation, :email))
      member.save!
    end
  end
  def participate!(participated_event)
    relationships.create!(participated_id: participated_event.id)
  end
  def cancel!(participated_event)
    relationships.find_by(participated_id: participated_event.id).destroy
  end
end
