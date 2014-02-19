# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require "csv"

users = ["1192373388","100002154842395","100001781966894","100001139319635","100000835756773","100001492420474"]
users.each do |user|
  User.create(uid: user)
end
puts "ユーザー読込完了"

categories = ["起業家","投資家","起業家予備軍","プロフェッショナル","金融マン","事業会社勤務","政府関係者","研究者／大学関係者","フリーランス","学生"]
categories.each do |category|
  Category.create(name: category)
end
puts "メンバーカテゴリ読込完了"

places = ["泉ガーデン","ソリトン","ディレクターズカフェ","新日本監査法人","あずさ監査法人"]
places.each do |place|
  Place.create(name: place)
end
puts "会場読込完了"

CSV.foreach('db/fb_event_id.csv', headers: true) do |row|
  Event.create! row.to_hash
end
puts "イベント情報読込完了"

CSV.foreach('db/gtic_member.csv', headers: true) do |row|
  Member.create! row.to_hash
end
puts "GTICメンバー読込完了"

