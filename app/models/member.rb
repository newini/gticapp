class Member < ActiveRecord::Base
  # Email check
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_many :relationships, foreign_key: "member_id", dependent: :destroy
  has_many :events, through: :relationships, source: :event
  has_many :registed_events, -> { where "status = 2"}, through: :relationships, source: :event
  has_many :participated_events, -> { where "status = 3 or status = 6"}, through: :relationships, source: :event # with dotasan
  has_many :presentationships, foreign_key: "member_id", dependent: :destroy
  has_many :presentations, through: :presentationships, source: :presentation
#  has_many :presentations, foreign_key: "member_id", dependent: :destroy

  # Broadcast
  has_many :broadcast_members
  has_many :broadcast, through: :broadcast_members

  # Staff
  has_one :staff

# scope
  scope :find_member, ->(keyword) { where(
      "last_name like ?
      OR first_name like ?
      OR last_name_alphabet like ?
      OR first_name_alphabet like ?
      OR name like ?
      OR last_name||first_name like ?
      OR first_name_alphabet||last_name_alphabet like ?
      OR affiliation like ?
      OR title like ?
      OR note like ?",
      "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%",
      "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%",
      "%#{keyword}%", "%#{keyword}%"
  ) }
  scope :find_member_name, ->(name) { where(
      "last_name like ?
      OR first_name like ?
      OR last_name_alphabet like ?
      OR first_name_alphabet like ?
      OR name like ?
      OR last_name||first_name like ?
      OR first_name_alphabet||last_name_alphabet like ?",
      "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%",
      "%#{name}%", "%#{name}%", "%#{name}%"
  ) }
  scope :sort_by_role_alphabet, -> {
    order("gtic_flg desc")
    .order(Arel.sql("relationships.presentation_role = 1 desc"))
    .order(Arel.sql("relationships.presentation_role = 2 desc"))
    .order(Arel.sql("relationships.presentation_role = 3 desc"))
    .order(Arel.sql("relationships.presentation_role = 4 desc"))
    .order("past_presenter_flg desc")
    .order("last_name_alphabet asc")
  }
  scope :recorded_member, ->(event) { joins(:relationships).where(relationships: {event_id: event.id}).where(relationships: {status: 2..6}).uniq }
  scope :waiting_member, ->(member) { where.not(id: member).order("last_name_alphabet") }

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

  def member_tokens=(ids)
    self.member_ids = ids.split(",")
  end

  # For user
  def self.from_user(user)
    member = Member.where(last_name: user.last_name, first_name: user.first_name).first_or_create
    member.update(
      last_name_alphabet:   user.last_name_alphabet,
      first_name_alphabet:  user.first_name_alphabet,
      category_id:          user.category_id,
      affiliation:          user.affiliation,
      title:                user.title,
      provider:             user.provider,
      uid:                  user.uid,
      name:                 user.name,
      email:                user.email
    )
    return member
  end



end
