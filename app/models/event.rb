class Event < ActiveRecord::Base
  validates :name, presence:true, length: { maximum: 50 }
  has_many :relationships, foreign_key: "event_id", dependent: :destroy
  has_many :members, through: :relationships, source: :member
  has_many :registed_members, -> { where "status = 2"}, through: :relationships, source: :member 
  has_many :participants, -> { where "status = 3"}, through: :relationships, source: :member 
  has_many :canceled_members, -> {where "status = 4"}, through: :relationships, source: :member 
  has_many :no_show, -> {where "status = 5"}, through: :relationships, source: :member 
  has_many :presenters, -> {where :relationships => {presenter_flg: true}}, through: :relationships, source: :member
  has_many :invitations, dependent: :destroy
  has_many :presentations, foreign_key: "event_id", dependent: :destroy
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

  def self.check_facebook_update
    base_url = 'https://graph.facebook.com/oauth/access_token'
    app_id = Settings.OmniAuth.facebook.app_id
    app_secret = Settings.OmniAuth.facebook.app_secret
    user = User.find_by_name("Fuminori Sugawara")
    user_access_token = user.access_token
    req_url = "#{base_url}?grant_type=fb_exchange_token&client_id=#{app_id}&client_secret=#{app_secret}&fb_exchange_token=#{user_access_token}"
    response = Net::HTTP.get_response(URI.parse(req_url))
    key = response.body.split("&").first.split("=").last
    user.update(access_token: key)
    user.save!
    status = "attending"
    events = Event.where("start_time >= ?", DateTime.now)
    graph = Koala::Facebook::API.new(key)
    events.each do |event|
      fb_event_id = event.fb_event_id
      if fb_event_id.present?
        fb_members = graph.get_connections(fb_event_id, status, locale: "jp_JP")
        fb_members.each do |fb_member|
          fb_name = fb_member["name"]
          fb_user_id = fb_member["id"]
          if Member.find_by_fb_user_id(fb_user_id).present?
            @member = Member.find_by_fb_user_id(fb_member["id"])
            @member.update(fb_name: fb_name, fb_user_id: fb_user_id)
          else
            @member = Member.new(fb_name: fb_name, fb_user_id: fb_user_id)
          end
          @member.save!
          if @member.relationships.find_by_event_id(event.id).blank?
            @relationship = @member.relationships.new(event_id: event.id, status: 2)
            @relationship.save!
          elsif @member.relationships.find_by_event_id(event.id).status < 2
            @relationship = @member.relationships.find_by_event_id(event.id)
            @relationship.update(event_id: event.id, status: 2)
            @relationship.save!
          end
        end
      end
    end
  end

end
