# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require "csv"
User.create(name: "Fuminori", email: "test@example.com", password: "hogehoge", password_confirmation: "hogehoge")

categories = ["起業家","投資家","起業家予備軍","プロフェッショナル","金融マン","事業会社勤務","政府関係者","研究者／大学関係者","フリーランス","学生"]
categories.each do |category|
  Category.create(name: category)
end

places = ["泉ガーデン","ソリトン","ディレクターズカフェ","新日本監査法人","あずさ監査法人"]
places.each do |place|
  Place.create(name: place)
end

CSV.foreach('db/fb_event_id.csv', headers: true) do |row|
  Event.create! row.to_hash
end

CSV.foreach('db/gtic_member.csv', headers: true) do |row|
  Member.create! row.to_hash
end

