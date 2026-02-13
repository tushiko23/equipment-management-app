# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 1. カテゴリを作成
puts "カテゴリを作成中..."
pc_cat = Category.create!(name: "PC・周辺機器")
book_cat = Category.create!(name: "書籍")
other_cat = Category.create!(name: "その他")

# 2. 備品を作成
puts "備品を作成中..."
Item.create!(
  name: "MacBook Pro M3",
  unique_id: "PC-001",
  description: "開発用のハイスペックマシンです。",
  state: :available, # 貸出可
  category: pc_cat
)

Item.create!(
  name: "プロを目指す人のためのRuby入門",
  unique_id: "BK-001",
  description: "チェリー本です。新人研修用。",
  state: :borrowed, # 貸出中（テスト用）
  category: book_cat
)

Item.create!(
  name: "HDMI変換アダプタ",
  unique_id: "OT-001",
  description: "Type-CからHDMIへの変換用。",
  state: :available,
  category: pc_cat
)

puts "初期データの投入完了！"
