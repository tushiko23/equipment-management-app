require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  let!(:admin) { User.create!(name: "管理者", email: "admin@example.com", password: "password123", role: :admin) }
  let!(:user_a) { User.create!(name: "利用者A", email: "a@example.com", password: "password123") }
  let!(:user_b) { User.create!(name: "利用者B", email: "b@example.com", password: "password123") }
  let!(:category) { Category.find_or_create_by!(name: "事務用品") }
  let!(:item) { Item.create!(name: "ハサミ", unique_id: "H01", category: category, state: :available) }

  # Aさん宛の通知
  let!(:notification_a) { Notification.create!(user: user_a, item: item, message: "返却してください") }

  describe "PATCH /notifications/:id" do
    context "他のユーザー（Bさん）としてログインしている場合" do
      before { sign_in user_b }

      it "Aさん宛の通知に勝手に返信しようとすると、更新されずにリダイレクトされること" do
        patch notification_path(notification_a), params: {
          notification: { reply_message: "Bが勝手に返信！" }
        }

        expect(notification_a.reload.reply_message).to be_nil
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
