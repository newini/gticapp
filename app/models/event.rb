class Event < ActiveRecord::Base
  validates :name, presence:true, length: { maximum: 50 }
  has_many :relationships, foreign_key: "event_id", dependent: :destroy
  has_many :members, through: :relationships, source: :member
  has_many :maybe_members, -> { where "status = 1"}, through: :relationships, source: :member
  has_many :registed_members, -> { where "status = 2"}, through: :relationships, source: :member
  has_many :dotasan, -> {where "status = 6"}, through: :relationships, source: :member
  has_many :declined_members, -> {where "status = 0 or status = 4"}, through: :relationships, source: :member
  has_many :dotacan, -> {where "status = 7"}, through: :relationships, source: :member
  has_many :no_show, -> {where "status = 5"}, through: :relationships, source: :member
  has_many :invited_members, -> {where "status = 1"}, through: :relationships, source: :member # 未定者

  # presenter, panelist, moderator
  has_many :presenters, -> {where :relationships => {presentation_role: 1..3}}, through: :relationships, source: :member
  has_many :search_presenter, ->(keyword) { where :relationships => {presentation_role: 1..3}}, through: :relationships, source: :member
  has_many :guests, -> {where :relationships => {guest_flg: true}}, through: :relationships, source: :member
  has_many :participants, -> { where "status = 3 or status = 6"}, through: :relationships, source: :member

  has_many :invitations, dependent: :destroy
  has_many :presentationships, foreign_key: "event_id", dependent: :destroy
  has_many :presentations, -> { distinct }, through: :presentationships, source: :presentation
  has_many :registers, foreign_key: "event_id", dependent: :destroy
  has_many :accounts, through: :registers, source: :account

  belongs_to :event_category
  belongs_to :place
#  has_many :presentations, foreign_key: "event_id", dependent: :destroy


  # =========================================================
  # scopes
  scope :year_between, ->(year) { where(:start_time => Date.parse(year).beginning_of_year..Date.parse(year).end_of_year) }

end
