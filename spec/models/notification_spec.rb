require 'rails_helper'

RSpec.describe Notification, type: :model do
  # 1. テストデータの準備
  let(:user) { User.create!(name: "利用者", email: "user@example.com", password: "password123") }
  let(:category) { Category.find_or_create_by!(name: "事務用品") }
  let(:item) { Item.create!(name: "ハサミ", unique_id: "H01", category: category, state: :available) }

  describe "バリデーションの検証" do
    it "必要な項目があれば有効であること" do
      notification = Notification.new(
        user: user,
        item: item,
        message: "返却期限または期限が過ぎています。"
      )
      expect(notification).to be_valid
    end

    it "メッセージ（message）が空の場合は無効であること" do
      notification = Notification.new(message: nil)
      notification.valid?
      expect(notification.errors[:message]).to include("を入力してください")
    end
  end

  describe "デフォルト値の検証" do
    let(:notification) { Notification.create!(user: user, item: item, message: "テスト通知") }

    it "作成時、既読フラグ（read）は false であること" do
      expect(notification.read).to be false
    end

    it "作成時、管理者確認フラグ（checked）は false であること" do
      expect(notification.checked).to be false
    end
  end

  describe "返信機能の検証" do
    it "返信メッセージ（reply_message）を保存できること" do
      notification = Notification.create!(user: user, item: item, message: "テスト通知")
      notification.update(reply_message: "明日返却します。")
      expect(notification.reload.reply_message).to eq "明日返却します。"
    end
  end
end
