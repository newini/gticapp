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
  has_many :invited_members, -> {where "member_id = 1884"}, through: :relationships, source: :member

  # presenter, panelist, moderator
  has_many :presenters, -> {where :relationships => {presentation_role: 1..3}}, through: :relationships, source: :member
  has_many :search_presenter, ->(keyword) { where :relationships => {presentation_role: 1..3}}, through: :relationships, source: :member
  has_many :guests, -> {where :relationships => {guest_flg: true}}, through: :relationships, source: :member
  has_many :participants, -> { where "status = 3 or status = 6"}, through: :relationships, source: :member

  has_many :invitations, dependent: :destroy
  has_many :presentationships, foreign_key: "event_id", dependent: :destroy
  has_many :presentations, -> { uniq }, through: :presentationships, source: :presentation
  has_many :registers, foreign_key: "event_id", dependent: :destroy
  has_many :accounts, through: :registers, source: :account
#  has_many :presentations, foreign_key: "event_id", dependent: :destroy

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Event.create! row.to_hash
    end
  end

  # Import registed members from FB event page in CSV
  def self.import_registed_members(file, event_id)
    i = total = 0
    problem_names = []
    not_registed_names = []
    registed_members = Event.find(event_id).registed_members
    registed_members.each do |member|
      not_registed_names.push(member.last_name+member.first_name)
    end

    CSV.foreach(file.path) do |row| # Array, 0-->name, status
      if row[1].include? "参加予定"
        members = []
        name = row[0].gsub(/　/, " ") # convert zenkaku space to space
        words = name.to_s.lstrip.rstrip.split(" ") # name --> to string --> remove space left leading --> remove space right tailing --> split by space
        words.each_with_index do |w, index|
          if index == 0
            members = Member.find_member_name(w)
          else
            members = members.find_member_name(w)
          end
        end

        if members.count == 1
          member = members[0]
          relationship = Relationship.where(event_id: event_id).find_by_member_id(member.id) || Relationship.new
          relationship.update(member_id: member.id, event_id: event_id, status: 2 )

          if not_registed_names.include?(member.last_name+member.first_name)
            not_registed_names.delete(member.last_name+member.first_name)
          end

          i += 1
        else
          problem_names.push(row[0])
        end
        total += 1
      end
    end

    return i, total, problem_names, not_registed_names
  end

  def self.import_participants(file, event_id)
    i = total = 0
    problem_names = []
    CSV.foreach(file.path) do |row| # Array, 0-->name, afflication, title, mail1, mail2, mail3, mail4, tel1, ...
      members = []
      name = row[0].gsub(/　/, " ") # convert zenkaku space to space
      words = name.to_s.lstrip.rstrip.split(" ") # name --> to string --> remove space left leading --> remove space right tailing --> split by space
      words.each_with_index do |w, index|
        if index == 0
          members = Event.find(event_id).participants.find_member_name(w)
        else
          members = members.find_member_name(w)
        end
      end

      if members.count == 1
        member = members[0]
        member.update(affiliation: row[1]) if member.affiliation.blank?
        member.update(title: row[2]) if member.title.blank?
        member.update(email: row[3]) if member.email.blank?
        i += 1
      else
        problem_names.push(row[0])
      end
      total += 1
    end
    return i, total, problem_names
  end

  def self.import_participants_from_xlsx(file, event_id) # CamCard
    i = total = 0
    problem_names = []

    xlsx = Roo::Excelx.new(file.path)
    xlsx.each(name: "Name", companay1: "Company1", department1: "Department1", title1: "Title1", email1: "Email1") do |row|
      if row[:name] == "Name"
        next
      end

      members = []
      name = row[:name].gsub(/　/, " ") # convert zenkaku space to space
      words = name.to_s.lstrip.rstrip.split(" ") # name --> to string --> remove space left leading --> remove space right tailing --> split by space
      words.each_with_index do |w, index|
        if index == 0
          members = Event.find(event_id).participants.find_member_name(w)
        else
          members = members.find_member_name(w)
        end
      end

      if members.count == 1
        member = members[0]
        member.update(affiliation: row[:companay1]) if member.affiliation.blank?
        member.update(title: row[:title1]) if member.title.blank?
        member.update(title: row[:department1]) if member.title.blank?
        member.update(email: row[:email1]) if member.email.blank?
        i += 1
      else
        problem_names.push(row[:name])
      end
      total += 1
    end
    return i, total, problem_names
  end

  def self.import_from_questionnaire(file, event_id)
    i = total = 0
    problem_names = []
    CSV.foreach(file.path) do |row| # Array = 0-->time, name, gender, birthmonth, company, title, ...
      members = []
      name = row[1].gsub(/　/, " ") # convert zenkaku space to space
      words = name.to_s.lstrip.rstrip.split(" ") # name --> to string --> remove space left leading --> remove space right tailing --> split by space
      words.each_with_index do |w, index|
        if index == 0
          members = Event.find(event_id).participants.find_member_name(w)
        else
          members = members.find_member_name(w)
        end
      end

      if members.count == 1
        member = members[0]

        if row[2].present? && member.gender.blank? # Gender
          if row[2].include? "Male"
            member.update(gender: 1)
          elsif row[2].include? "Female"
            member.update(gender: 2)
          end
        end

        if row[3].present? && member.age.blank? # Age
          if row[3].include? "20s"
            member.update(age: 1)
          elsif row[3].include? "30s"
            member.update(age: 2)
          elsif row[3].include? "40s"
            member.update(age: 3)
          elsif row[3].include? "50s"
            member.update(age: 4)
          elsif row[3].include? "60s"
            member.update(age: 5)
          end
        end

        if row[4].present? && member.birthday.blank? # Birth Month
          if row[4].include? "Jan"
            member.update(birthday: "2000-01-01")
          elsif row[4].include? "Feb"
            member.update(birthday: "2000-02-01")
          elsif row[4].include? "Mar"
            member.update(birthday: "2000-03-01")
          elsif row[4].include? "Apr"
            member.update(birthday: "2000-04-01")
          elsif row[4].include? "May"
            member.update(birthday: "2000-05-01")
          elsif row[4].include? "Jun"
            member.update(birthday: "2000-06-01")
          elsif row[4].include? "Jul"
            member.update(birthday: "2000-07-01")
          elsif row[4].include? "Aug"
            member.update(birthday: "2000-08-01")
          elsif row[4].include? "Sep"
            member.update(birthday: "2000-09-01")
          elsif row[4].include? "Oct"
            member.update(birthday: "2000-10-01")
          elsif row[4].include? "Nov"
            member.update(birthday: "2000-11-01")
          elsif row[4].include? "Dec"
            member.update(birthday: "2000-12-01")
          end
          i += 1
        end

        if row[5].present? && member.affiliation.blank? # Affiliation
          member.update(affiliation: row[5])
        end

        if row[6].present? && member.title.blank? # Title
          member.update(title: row[6])
        end

        if row[7].present? && member.category_id.blank? # Category
          category_id = Category.find_by_name(row[7])
          member.update(category_id: category_id)
        end

      else
        problem_names.push(row[1])
      end
      total += 1
    end
    return i, total, problem_names
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
    statuses = ["attending", "maybe", "declined"]
    events = Event.where("start_time >= ?", DateTime.now)
    graph = Koala::Facebook::API.new(key)
    events.each do |event|
      fb_event_id = event.fb_event_id
      if fb_event_id.present?
        statuses.each do |status|
          fb_members = graph.get_connections(fb_event_id, status, locale: "jp_JP")
          fb_members.each do |fb_member|
            fb_name = fb_member["name"]
            fb_user_id = fb_member["id"]
            if Member.find_by_fb_user_id(fb_user_id).present?
              @member = Member.find_by_fb_user_id(fb_user_id)
              @member.update(fb_name: fb_name, fb_user_id: fb_user_id)
            else
              @member = Member.new(fb_name: fb_name, fb_user_id: fb_user_id)
            end
            @member.save!
            if record = @member.relationships.find_by_event_id(event.id)
              unless record.status == Event.convert_status(status)
                case record.status
                when nil, 0, 1, 2
                    record.update(event_id: event.id, status: Event.convert_status(status))
                    record.save!
                    ScheduleLog.create(event_id: event.id, status: Event.convert_status(status), member_id: @member.id)
                end
              end
            else
              @member.relationships.create(event_id: event.id, status: Event.convert_status(status))
              ScheduleLog.create(event_id: event.id, status: Event.convert_status(status), member_id: @member.id)
            end
          end
        end
      end
    end
  end

  def self.convert_status(rsvp_status)
    case rsvp_status
    when "declined"
      0
    when "maybe"
      1
    when "attending"
      2
    end
  end

  #scope
  scope :year_between, ->(year) { where(:start_time => Date.parse(year).beginning_of_year..Date.parse(year).end_of_year) }

end
