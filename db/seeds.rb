# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Skill.delete_all
Skill.create([
  { name: "天使のつぶやき", description: "伏せられた4枚のカードの数字を教えてくれる。（順番はランダム。）", skill_type: 1, price: 100 },
  { name: "悪魔のささやき", description: "伏せられた一番左のカードの数字を教えてくれる。（但し1/3の確率で嘘である。）", skill_type: 2, price: 100 },
  { name: "天使の約束", description: "4枚中2枚を相手カード以上に変える。（残りの2枚は通常通り抽選される。）", skill_type: 1, price: 500 },
  { name: "悪魔の契約", description: "所持コインオールイン時のみ発動。4枚中3枚を相手カード以上に変える。（残りの1枚は通常通り抽選される。）", skill_type: 2, price: 500 },
  { name: "勝利の女神", description: "4枚中3枚を相手カード以上に変える。（残りの1枚は通常通り抽選される。）", skill_type: 3, price: 1000 },
  { name: "強欲の魔神", description: "勝利時に得られるコインの配当が2倍→3倍", skill_type: 4, price: 1000 },
  { name: "堕天使の大罪", description: "天界スキルと魔界スキルを1つずつ装備できる。", skill_type: 5, price: 1000 },
  { name: "V.I.P", description: "遊んでくれてありがとう！", skill_type: 6, price: 10000 },
])