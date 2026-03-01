require 'selenium-webdriver'
require 'rails_helper'

RSpec.describe "カテゴリー管理", type: :system do
  let!(:random_password) { (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join }
  let!(:admin_user) { User.create!(email: "admin@example.com", password: random_password, role: :admin, name: "admin_example") }
  let!(:category_pc) { Category.create(name: "PC周辺機器") }
  let!(:category_stationery) { Category.create(name: "文房具") }
  let!(:category_clean) { Category.create!(name: "未使用カテゴリー") }
  let!(:category_with_item) { Category.create!(name: "使用中カテゴリー") }
  let!(:item) { Item.create!(name: "テストPC", category: category_with_item, unique_id: "0004") }

  before do
    login_as(admin_user)
    visit admin_categories_path
  end

  describe "検索機能のテスト" do
    context "『PC』と入力して検索した場合" do
      it "『PC周辺機器』が表示され、『文房具』が表示されないこと" do
        # 1. 検索窓に「PC」と入力する
        fill_in "q_name_cont", with: "PC"
        
        # 2. 検索ボタンをクリックする
        click_on "検索"

        # 3. 期待する結果を確認する
        expect(page).to have_content "PC周辺機器"
        expect(page).to_not have_content "文房具"
      end
    end
  end

  describe "作成機能" do
      it "カテゴリー名を空で登録しようとするとエラーが出ること" do
      visit new_admin_category_path
      fill_in "カテゴリー名", with: ""
      click_on "カテゴリーの作成"

      expect(page).to have_content "カテゴリー名を入力してください"
      expect(page).to have_content "カテゴリー作成"
    end

    it "カテゴリー名を既存のものにするとエラーが出ること" do
      visit new_admin_category_path
      fill_in "カテゴリー名", with: "文房具"
      click_on "カテゴリーの作成"

      expect(page).to have_content "カテゴリー名はすでに存在します"
      expect(page).to have_content "カテゴリー作成"
    end
    it "新しいカテゴリーを作成できること" do
      click_on "カテゴリー登録" # 画面上のボタン名に合わせて調整してください
      fill_in "カテゴリー名", with: "キッチン用品" # ラベル名に合わせて調整
      click_on "カテゴリーの作成"
      
      expect(page).to have_content "カテゴリーが新規作成されました"
      expect(page).to have_content "キッチン用品"
    end
  end


  describe "編集機能" do
    it "既存のカテゴリーを編集できること" do
      # PC周辺機器の横にある「編集」リンクをクリック
      within "tr", text: "PC周辺機器" do
        click_on "編集する"
      end

      fill_in "カテゴリー名", with: "ガジェット"
      click_on "カテゴリーの編集"

      expect(page).to have_content "カテゴリーが更新されました"
      expect(page).to have_content "ガジェット"
      expect(page).to_not have_content "PC周辺機器"
    end

    it "アイテムに紐づいていたら編集ボタンが押せないこと" do
      within "tr", text: "使用中カテゴリー" do
        # 🌟 「編集不可」というただの文字が表示されていること
        expect(page).to have_content "編集不可"
        # 🌟 クリックできる「編集」リンクが存在しないこと
        expect(page).not_to have_link "編集する"
      end
    end
  end

    describe "削除機能" do
    it "既存のカテゴリーを削除できること" do
      # 使用中カテゴリーの横にある「削除」リンクをクリック
      within "tr", text: "未使用カテゴリー" do
        accept_confirm do
          click_on "削除する"
        end
      end
      expect(page).to have_content "カテゴリーが削除されました"
    end

    it "アイテムに紐づいている時削除ボタンが押せない" do
      within "tr", text: "使用中カテゴリー" do
        expect(page).to have_link "削除する", class: "disabled"
      end
    end
  end
end
