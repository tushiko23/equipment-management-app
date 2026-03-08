# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 サンプルデータの作成を開始します..."

  # ===================================================
  # 1. ユーザーデータの作成
  # ===================================================
  # （悠人さんが書いた スーパー管理者、管理者、一般ユーザー、山田太郎、佐藤花子 のコードはそのまま残します）
  # ... [悠人さんの既存のユーザー作成コード] ...

  # 🌟 ゲストログイン用：ゲスト管理者
  guest_admin = User.find_or_create_by!(email: "admin_guest@example.com") do |user|
  user.name = "管理者ゲスト"
  user.password = (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join
  user.password_confirmation = user.password
  user.role = "admin"
  user.can_create_general_users = true
  user.can_edit_general_users   = true
  user.can_delete_general_users = false
end


guest_user = User.find_or_create_by!(email: "guest@example.com") do |user|
  user.name = "一般ゲスト"
  user.password = (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join
  user.password_confirmation = user.password
  user.role = "general"
end

# 使いやすいように変数に入れておく
admin_user = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.name = "管理者"
  user.password =  (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join
  user.password_confirmation = user.password
  user.role = "admin"
end

test_user1 = User.find_or_create_by!(email: "test1@example.com") do |user|
  user.name = "山田太郎"
  user.password =  (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join
  user.password_confirmation = user.password
  user.role = "general"
end

puts "👤 ユーザーの作成が完了しました"


# ===================================================
# 2. カテゴリーとタグの作成
# ===================================================
cat_pc      = Category.find_or_create_by!(name: "PC本体")
cat_monitor = Category.find_or_create_by!(name: "モニター")
cat_cable   = Category.find_or_create_by!(name: "ケーブル・周辺機器")
cat_book    = Category.find_or_create_by!(name: "技術書")

tag_mac   = Tag.find_or_create_by!(name: "Mac")
tag_win   = Tag.find_or_create_by!(name: "Windows")
tag_typec = Tag.find_or_create_by!(name: "Type-C")
tag_ruby  = Tag.find_or_create_by!(name: "Ruby")

puts "🏷️ カテゴリーとタグの作成が完了しました"


# ===================================================
# 3. アイテムの作成
# ===================================================
# ① 貸出可能なアイテム（すぐ借りられる状態）
item_mac = Item.find_or_create_by!(unique_id: "PC-001") do |item|
  item.name = "MacBook Pro 14インチ (M2)"
  item.category = cat_pc
  item.state = :available
end
item_mac.tags = [ tag_mac, tag_typec ] unless item_mac.tags.present?

# ② 貸出中のアイテム（一般ゲストが現在借りている）
item_monitor = Item.find_or_create_by!(unique_id: "MN-001") do |item|
  item.name = "Dell 27インチ 4Kモニター"
  item.category = cat_monitor
  # 💡 修正ポイント1：モデルのenumで定義している名前にしてください！（ここでは仮で :lent にしています）
  item.state = :borrowed
end
item_monitor.tags = [ tag_typec ] unless item_monitor.tags.present?

# ③ 貸出中・しかも期限切れのアイテム
item_book = Item.find_or_create_by!(unique_id: "BK-001") do |item|
  item.name = "プロを目指す人のためのRuby入門"
  item.category = cat_book
  item.state = :borrowed# 💡 ここも同様に修正
end
item_book.tags = [ tag_ruby ] unless item_book.tags.present?

# ④ メンテナンス中のアイテム
item_win = Item.find_or_create_by!(unique_id: "PC-002") do |item|
  item.name = "ThinkPad X1 Carbon"
  item.category = cat_pc
  item.state = :maintenance # 💡 ここも必要に応じて修正
end
item_win.tags = [ tag_win ] unless item_win.tags.present?

puts "💻 アイテムの作成が完了しました"


# ===================================================
# 4. 貸出データ（Lending）の作成
# ===================================================
# ① 一般ゲストがモニターを借りている（期限内）
lending_monitor = Lending.find_or_initialize_by(item: item_monitor, user: guest_user, returned_at: nil)
if lending_monitor.new_record?
  lending_monitor.lent_at = Time.current
  lending_monitor.due_at = Time.current.since(7.days)
  # 💡 バリデーション（貸出中チェックなど）を無視して強制保存！
  lending_monitor.save(validate: false)
end

# ② 山田太郎が技術書を借りていて、期限切れになっている（督促テスト用）
lending_book = Lending.find_or_initialize_by(item: item_book, user: test_user1, returned_at: nil)
if lending_book.new_record?
  lending_book.lent_at = Time.current.ago(14.days)
  lending_book.due_at = Time.current.ago(7.days)
  # 💡 バリデーション（期限が過去であってはいけない等）を無視して強制保存！
  lending_book.save(validate: false)
end

puts "📦 貸出状況の作成が完了しました"


# ===================================================
# 5. 通知（Notification）の作成
# ===================================================
# ゲストユーザーがログインした時に「通知が来ている！」と分かるようにするテストデータ
Notification.find_or_create_by!(user: guest_user, item: item_monitor) do |notification|
  notification.message = "【確認】Dell 27インチ 4Kモニターの利用状況について、問題なく使えていますでしょうか？"
  notification.read = false # 未読状態
  notification.checked = false
end

# 山田太郎から管理者への返信がある状態（管理者がログインした時に返信を確認できるテストデータ）
Notification.find_or_create_by!(user: test_user1, item: item_book) do |notification|
  notification.message = "【督促】プロを目指す人のためのRuby入門の返却期限が過ぎています。至急返却してください。"
  notification.reply_message = "申し訳ありません！明日必ず出社時に返却します！"
  notification.read = true
  notification.checked = false # 管理者がまだ確認・完了にしていない状態
end

puts "🔔 通知データの作成が完了しました"
puts "🎉 全てのダミーデータの流し込みに成功しました！"
