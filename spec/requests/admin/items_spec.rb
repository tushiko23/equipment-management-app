require 'rails_helper'

RSpec.describe "Admin::Items (管理者権限の防御)", type: :request do
  let!(:general_user) do
    User.create!(email: "hacker_#{SecureRandom.hex(4)}@example.com", password: "password123", name: "一般ユーザー", role: :general)
  end

  let!(:category) { Category.find_or_create_by!(name: "テストカテゴリ") }
  let!(:item) { Item.create!(name: "ターゲットアイテム", unique_id: "T-#{SecureRandom.hex(2)}", category: category, state: :available) }

  before do
    sign_in general_user
  end

  describe "POST /admin/items (アイテムの不正作成)" do
    it "一般ユーザーが直接URLを叩いてアイテムを作成しようとすると、弾かれてリダイレクトされること" do
      post admin_items_path, params: {
        item: { name: "不正なアイテム", unique_id: "BAD-01", category_id: category.id }
      }

      expect(response).to have_http_status(:redirect)
      expect(Item.find_by(name: "不正なアイテム")).to be_nil
    end
  end

  describe "PATCH /admin/items/:id (アイテムの不正編集)" do
    it "一般ユーザーが直接URLを叩いてアイテムを編集しようとすると、弾かれてリダイレクトされること" do
      patch admin_item_path(item), params: {
        item: { name: "ハッカーが勝手に変えた名前" }
      }

      expect(response).to have_http_status(:redirect)
      expect(item.reload.name).to eq "ターゲットアイテム"
    end
  end

  describe "DELETE /admin/items/:id (アイテムの不正削除)" do
    it "一般ユーザーが直接URLを叩いてアイテムを削除しようとすると、弾かれてリダイレクトされること" do
      delete admin_item_path(item)
      expect(response).to have_http_status(:redirect)
      expect(Item.exists?(item.id)).to be true
    end
  end
end
