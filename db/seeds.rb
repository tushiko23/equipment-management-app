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
# puts "古いデータを削除中..."
# Lending.destroy_all
# Item.destroy_all
# Category.destroy_all
# Userは消さないでおきます（ログインできなくなると面倒なので）



# puts "カテゴリを作成中..."
# 

puts "🌱 サンプルデータの作成を開始します..."

# 1. スーパー管理者（全ての権限をマスターキーで突破できる最強の存在）
User.find_or_create_by!(email: "super@example.com") do |user|
  user.name = "スーパー管理者"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "super_admin" # enumの指定
  # ※スーパー管理者はコントローラーのロジックで全て許可されるので、個別の権限カラムはデフォルト(false)のままでOKです！
end

# 2. 管理者（一般ユーザーの作成・編集・削除ができる存在）
User.find_or_create_by!(email: "admin@example.com") do |user|
  user.name = "サブ管理者"
  user.password = "password1234"
  user.password_confirmation = "password1234"
  user.role = "admin"
  
  # ▼ ここにテスト用の権限を付与します ▼
  user.can_create_general_users = true
  user.can_edit_general_users   = true
  user.can_delete_general_users = true
  
  # （adminの管理権限は持たせない設定にしておきます）
  user.can_create_admin_users = false
  user.can_edit_admin_users   = false
  user.can_delete_admin_users = false
end

# 3. 一般ユーザー（権限を何も持たない存在）
User.find_or_create_by!(email: "general@example.com") do |user|
  user.name = "一般ユーザー"
  user.password = "password12345"
  user.password_confirmation = "password12345"
  user.role = "general"
end

# （おまけ）検索テスト用に、もう何人か一般ユーザーを作っておくと便利です！
User.find_or_create_by!(email: "test1@example.com") do |user|
  user.name = "山田 太郎"
  user.password = "password123456"
  user.password_confirmation = "password123456"
  user.role = "general"
end

User.find_or_create_by!(email: "test2@example.com") do |user|
  user.name = "佐藤 花子"
  user.password = "password1234567"
  user.password_confirmation = "password1234567"
  user.role = "general"
end

puts "✅ サンプルデータの作成が完了しました！"
