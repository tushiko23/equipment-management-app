# spec/system/admin/items_spec.rb
require 'rails_helper'

RSpec.describe "アイテム（備品）管理", type: :system do
  let!(:random_password) { (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join }
  let!(:admin_user) { User.create!(email: "admin@example.com", password: random_password, role: :admin, name: "admin_example") }
  let!(:category_pc) { Category.create!(name: "PC周辺機器") }
  let!(:category_other) { Category.create!(name: "その他") }
  let!(:existing_item) { Item.create!(name: "古いMacBook", unique_id: "9999", category: category_pc, state: :available) }

  before do
    login_as(admin_user)
    visit admin_items_path
  end
  describe "作成機能" do
    it "アイテムとタグを紐づけて新規作成できること" do
      click_on "登録"
      fill_in "item_name", with: "テスト用MacBook"
      fill_in "unique_id", with: "0001"
      select "PC周辺機器", from: "カテゴリー"
      select "貸出可", from: "ステータス"
      fill_in "タグ名", with: "新品"

      click_on "アイテムの作成"

      expect(page).to have_content "アイテムが新規作成されました"
      expect(page).to have_content "テスト用MacBook"
      expect(page).to have_content "新品"
    end

    context "入力値に不備がある場合" do
      it "アイテム名を空にするとエラーが出ること" do
        click_on "登録"
        fill_in "item_name", with: ""
        fill_in "unique_id", with: "0001"
        select "PC周辺機器", from: "カテゴリー"
        select "貸出可", from: "ステータス"

        click_on "アイテムの作成"

        expect(page).to_not have_content "アイテムが新規作成されました"
        expect(page).to have_content "アイテム名を入力してください"
      end

      it "管理番号を空にするとエラーが出ること" do
        click_on "登録"
        fill_in "item_name", with: "新品のMacBook"
        fill_in "unique_id", with: ""
        select "PC周辺機器", from: "カテゴリー"
        select "貸出可", from: "ステータス"

        click_on "アイテムの作成"

        expect(page).to_not have_content "アイテムが新規作成されました"
        expect(page).to have_content "管理番号を入力してください"
      end

      it "カテゴリー名を空にするとエラーが出ること" do
        click_on "登録"
        fill_in "item_name", with: "新品のMacBook"
        fill_in "unique_id", with: "0002"
        select "選択してください", from: "カテゴリー"
        select "貸出可", from: "ステータス"

        click_on "アイテムの作成"

        expect(page).to_not have_content "アイテムが新規作成されました"
        expect(page).to have_content "カテゴリーを入力してください"
      end
    end
  end

  describe "編集機能" do
    before do
      visit admin_item_path(existing_item)
    end

    context "入力値が正しい場合" do
      it "既存のアイテムを編集できること" do
        click_on "編集する"
        fill_in "item_name", with: "新品のMacBook"
        fill_in "unique_id", with: "0002"
        select "その他", from: "カテゴリー"
        select "メンテ中", from: "ステータス"

        click_on "編集する"

        expect(page).to have_content "アイテムの情報が更新されました"
        expect(page).to have_content "新品のMacBook"
        expect(page).to_not have_content "古いMacBook"
      end
    end

    context "入力値に不備がある場合" do
      it "アイテム名を空にすると更新できずエラーが出ること" do
        click_on "編集する"

        fill_in "item_name", with: ""

        click_on "編集する"

        expect(page).to_not have_content "アイテムの情報が更新されました"
        expect(page).to have_content "アイテム名を入力してください"
      end

      it "管理番号を空にすると更新できずエラーが出ること" do
        click_on "編集する"
        fill_in "unique_id", with: ""

        click_on "編集する"

        expect(page).to_not have_content "アイテムの情報が更新されました"
        expect(page).to have_content "管理番号を入力してください"
      end
    end
  end

  describe "削除機能" do
    before do
      visit admin_item_path(existing_item)
    end
    it "既存のアイテムを削除できること" do
        accept_confirm do
          click_on "削除する"
        end
      expect(page).to have_content "アイテムを削除しました"
      expect(page).to_not have_content "古いMacBook"
    end
  end
end
