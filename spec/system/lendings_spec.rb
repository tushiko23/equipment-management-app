# spec/system/lendings_spec.rb
require 'rails_helper'

RSpec.describe "貸出管理", type: :system do
  let!(:random_password) { (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join }
  let!(:user) { User.create!(email: "test@example.com", password: random_password, name: "テストユーザー") }
  let!(:category) { Category.create!(name: "PC周辺機器") }
  let!(:available_item) { Item.create!(name: "貸出可能のMac", unique_id: "L01", category: category, state: :available) }
  let!(:lent_item) { Item.create!(name: "貸出中のMac", unique_id: "L02", category: category, state: :borrowed) }
  let!(:maintenance_item) { Item.create!(name: "貸出中のMac", unique_id: "L03", category: category, state: :maintenance) }
  before do
    login_as(user)
  end

  it "貸出可のアイテムはボタンが表示され、借りることができる" do
    visit item_path(available_item)
    expect(page).to have_button "この備品を借りる"
    click_on "この備品を借りる"
    within("#borrowModal", visible: true) do
      expect(page).to have_content "貸出の手続き"
      fill_in "返却予定日", with: (Date.today + 1).to_s
      click_on "確定して借りる"
    end
    expect(page).to have_content "貸出処理が完了しました"
    expect(page).not_to have_button "この備品を借りる"
    expect(Lending.count).to eq 1
  end

  it "貸出中のアイテムで貸出ボタンが押せず現在貸出中と表示されること" do
    visit item_path(lent_item)

    expect(page).to_not have_button "この備品を借りる"
    # コントローラーのガード句で設定したメッセージが出るか確認
    expect(page).to have_button "現在貸出中です", disabled: true
    # 新しい貸出データが増えていないことを確認
    expect(Lending.count).to eq 0
  end

  it "メンテ中のアイテムには、借りるボタンが表示されず、現在メンテ中の押せないボタンが表示されること" do
    # 1. メンテ中アイテムの詳細ページへ行く
    visit item_path(maintenance_item)
    # 2. 借りるボタンがないことを確認
    expect(page).to_not have_button "現在貸出中です"
    expect(page).to_not have_button "この備品を借りる"
    # 3. 「現在メンテ中です」というボタンが disabled で存在することを確認
    expect(page).to have_button "現在メンテ中です", disabled: true
  end

  it "自分が借りているアイテムを返却できること" do
    # 1. 準備：lent_item と user を使って、貸出データ(Lending)を作成する
    Lending.create!(item: lent_item, lent_at: Date.current, due_at: Date.current, user: user)
    # 2. 実行：返却ボタンがあるページに行き、ボタンを押す
    visit lendings_path
    within ".card", text: "貸出中のMac" do
      click_on "返却する"
    end
    within("#returnedModal-#{lent_item.id}", visible: true) do
      expect(page).to have_content "返却の手続き"
      click_on "返却する"
    end
    # 4. 検証2：アイテム詳細ページへ行き、「借りる」ボタンが復活しているか確認する
    expect(page).to have_content "返却処理が完了しました"
    expect(page).not_to have_button "返却する"

    visit item_path(lent_item)
    expect(page).to have_content "この備品を借りる"
  end
end
