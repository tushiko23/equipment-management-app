# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 既存のデータをリセット（外部キー制約のエラーを防ぐため、子→親の順で消す）
puts "古いデータを削除中..."
Lending.destroy_all
Item.destroy_all
Category.destroy_all
# Userは消さないでおきます（ログインできなくなると面倒なので）

# # 1. カテゴリを作成
# puts "カテゴリを作成中..."
# pc_cat = Category.create!(name: "PC・周辺機器")
# book_cat = Category.create!(name: "書籍")
# other_cat = Category.create!(name: "その他")

# # 2. 備品を作成（貸出可のものを多めに！）
# puts "備品を作成中..."

# # --- PC関連 ---
# Item.create!(
#   name: "MacBook Pro M3 (14インチ)",
#   unique_id: "PC-001",
#   description: "最新のM3チップ搭載モデル。メモリ32GB。\n動画編集や重い処理もサクサク動きます。",
#   state: :available, # 貸出可
#   category: pc_cat
# )

# Item.create!(
#   name: "Dell 4Kモニター",
#   unique_id: "PC-002",
#   description: "27インチの4Kモニターです。Type-C接続対応。\n目に優しいブルーライトカット機能付き。",
#   state: :available, # 貸出可
#   category: pc_cat
# )

# Item.create!(
#   name: "iPad Air (第5世代)",
#   unique_id: "PC-003",
#   description: "検証端末として使ってください。\nApple Pencilも付属しています。",
#   state: :borrowed, # 貸出中（テスト用）
#   category: pc_cat
# )

# # --- 書籍 ---
# Item.create!(
#   name: "プロを目指す人のためのRuby入門",
#   unique_id: "BK-001",
#   description: "通称チェリー本。Rubyの基礎から応用まで学べます。\n新人研修の必読書です。",
#   state: :available, # 貸出可
#   category: book_cat
# )

# Item.create!(
#   name: "リーダブルコード",
#   unique_id: "BK-002",
#   description: "より良いコードを書くためのシンプルで実践的なテクニック。\n全エンジニアにおすすめ。",
#   state: :available, # 貸出可
#   category: book_cat
# )

# Item.create!(
#   name: "Webを支える技術",
#   unique_id: "BK-003",
#   description: "HTTP、URI、HTMLなどWebの基礎技術を歴史的背景から解説。\nRESTfulな設計の参考に。",
#   state: :maintenance, # メンテ中（テスト用）
#   category: book_cat
# )

# # --- その他 ---
# Item.create!(
#   name: "延長コード (3m)",
#   unique_id: "OT-001",
#   description: "会議室用です。6個口。",
#   state: :available, # 貸出可
#   category: other_cat
# )

# Item.create!(
#   name: "HDMI変換アダプタ",
#   unique_id: "OT-002",
#   description: "USB Type-CからHDMIへの変換用。",
#   state: :available, # 貸出可
#   category: other_cat
# )

#   User.create!(
#     name: "管理者ユーザーテスト",
#     password: "adminpassword123",
#     password_confirmation: "adminpassword123",
#     email: "admin-test@gmail.com",
#     role: 0
#   )

puts "データの削除が完了しました！"
