require 'rails_helper'

RSpec.describe "通知のやり取りフロー", type: :system do
  let!(:admin) { User.create!(name: "管理者", email: "admin@example.com", password: "password123", role: :admin) }
  let!(:user) { User.create!(name: "利用者太郎", email: "user@example.com", password: "password123", role: :general) }
  let!(:category) { Category.find_or_create_by!(name: "PC周辺機器") }
  let!(:item) { Item.create!(name: "共用iPad", unique_id: "I01", category: category, state: :available) }

  # 期限切れの貸出データを作っておく（管理者のダッシュボードに出現させるため）
  let!(:overdue_lending) do
    lending = Lending.new(
      user: user,
      item: item,
      lent_at: 1.week.ago,
      due_at: 1.day.ago # 昨日が期限
    )

    lending.save(validate: false)
    lending
  end

  it "管理者が通知を送り、ユーザーが返信し、管理者が完了にする一連の流れ" do
    login_as(admin)
    visit root_path

    within "#overdue-items-section" do
      within ".list-group-item", text: "共用iPad" do
        # 💡 修正点：確認ダイアログをOKする
        accept_confirm do
          click_on "お知らせする"
        end
      end
    end
    expect(page).to have_content "ユーザーに通知を送信しました！"
    # 💡 ここでログアウト！
    # 実際の一覧画面やヘッダーにあるボタン名に合わせてください
    Capybara.reset_sessions!

    # --- 2. 利用者のターン：届いた通知に返信 ---
    login_as(user)
    visit root_path

    expect(page).to have_content "管理者からの重要なお知らせ"
    fill_in "notification_reply_message", with: "すみません、明日必ず返します！"
    click_on "返信して確認"
    expect(page).to have_content "通知に返信し、確認済みにしました！"

    Capybara.reset_sessions!

    # --- 3. 管理者の最終確認：対応完了（checked: true）にする ---
    login_as(admin)
    visit root_path

    expect(page).to have_content "ユーザーからの返信"
    within "#user-replies-section" do
      within ".list-group-item", text: "利用者太郎" do
        expect(page).to have_content "すみません、明日必ず返します！"
        # 💡 修正点：ここも確認ダイアログが出るのでOKする
        accept_confirm do
          click_on "対応済みにする"
        end
      end
    end

    expect(page).to have_content "「対応済み」にしました！"

    expect(Notification.last.checked).to be true
  end
end
