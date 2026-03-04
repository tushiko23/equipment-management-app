require 'rails_helper'
RSpec.describe "コメントのUI表示", type: :system do
  # 1. 準備：ユーザー2人、アイテム1つ、それぞれのコメントを作成
  let!(:random_password) { (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join }
  let!(:user_a) { User.create!(email: "alice@example.com", password: random_password, name: "アリス") }
  let!(:user_b) { User.create!(email: "bob@example.com", password: random_password, name: "ボブ") }
  let!(:category) { Category.find_or_create_by!(name: "PC周辺機器") }
  let!(:item) { Item.create!(name: "共用MacBook", unique_id: "C01", category: category, state: :available) }

  let!(:comment_by_alice) { Comment.create!(content: "アリスのコメントです", user: user_a, item: item) }
  let!(:comment_by_bob) { Comment.create!(content: "ボブのコメントです", user: user_b, item: item) }

  context "アリスとしてログインしている場合" do
    before do
      login_as(user_a)
      visit item_comments_path(item)
    end

    it "自分のコメントには編集・削除ボタンが表示されること" do
      within "#comment_#{comment_by_alice.id}" do
        expect(page).to have_content "アリスのコメントです"
        expect(page).to have_link "編集"  # aタグならhave_link
        expect(page).to have_button "削除" # buttonタグならhave_button
      end
    end

    it "他人のコメントには編集・削除ボタンが表示されないこと" do
      within "#comment_#{comment_by_bob.id}" do
        expect(page).to have_content "ボブのコメントです"
        expect(page).not_to have_link "編集"
        expect(page).not_to have_button "削除"
      end
    end
  end
end
