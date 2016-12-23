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
  has_many :presentationships, foreign_key: "member_id", dependent: :destroy
  has_many :presentations, through: :presentationships, source: :presentation
#  has_many :presentations, foreign_key: "member_id", dependent: :destroy
#scope
  scope :find_name, ->(name) { where("fb_name like ? OR last_name like ? OR last_name_alphabet like ? OR first_name like ? OR first_name_alphabet like ?", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%" ) }
  scope :sort_by_role_alphabet, -> { order("gtic_flg desc").order("relationships.presentation_role desc").order("relationships.guest_flg desc").order("last_name_alphabet asc")}
  scope :sort_by_role_alphabet, -> { order("gtic_flg desc").order("relationships.presentation_role desc").order("relationships.guest_flg desc").order("last_name_alphabet asc")}
  scope :recorded_member, ->(event) { joins(:relationships).where(relationships: {event_id: event.id}).where(relationships: {status: 2..6}).uniq }
  scope :waiting_member, ->(member) { where.not(id: member).order("last_name_alphabet") }


  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      if member = Member.find_by_fb_user_id(row["fb_user_id"])
        parameters = ActionController::Parameters.new(row.to_hash)
        member.update(parameters.permit(:last_name, :first_name, :fb_name, :affiliation, :email))
        if member.last_name.present?
          member.update(last_name_alphabet: Member.kana(member.last_name))
        end
        member.save
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
  def self.kana(kanji)
    sentence = kanji
    sentence = URI.encode(sentence)
    key = 'dj0zaiZpPVR3TzJrbEJzRjRwTCZzPWNvbnN1bWVyc2VjcmV0Jng9OTg-'
    base_url = 'http://jlp.yahooapis.jp/FuriganaService/V1/furigana'
    req_url = "#{base_url}?sentence=#{sentence}&appid=#{key}"
    response = Net::HTTP.get_response(URI.parse(req_url))
    status = Hash.from_xml(response.body)
    begin
      words = status["ResultSet"]["Result"]["WordList"]
      value = String.new
      if words.length == 1
        value << words["Word"]["Furigana"]
      else
        words.each do |word|
          if word["Furigana"].nil?
            value << word["Word"]["Surface"]
          else
            value << word["Word"]["Furigana"]
          end
        end
      end
    rescue
      value = nil
    end
    value
  end

  def member_tokens=(ids)
    self.member_ids = ids.split(",")
  end


end
