# spec/system/lendings_spec.rb
require 'rails_helper'

RSpec.describe "貸出管理", type: :system do
  let!(:random_password) { (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join }
  let!(:user) { User.create!(email: "test_#{SecureRandom.hex(4)}@example.com", password: "password123", name: "テストユーザー") }
  let!(:category) { Category.find_or_create_by!(name: "PC周辺機器") }
  let!(:available_item) { Item.create!(name: "貸出可能のMac", unique_id: "L01", category: category, state: :available) }
  let!(:lent_item) { Item.create!(name: "貸出中のMac", unique_id: "L02", category: category, state: :borrowed) }
  let!(:maintenance_item) { Item.create!(name: "貸出中のMac", unique_id: "L03", category: category, state: :maintenance) }
  before do
    login_as(user)
  end

  it "貸出可のアイテムはボタンが表示され、借りることができる" do
    visit item_path(available_item)
    expect(page).to have_button "このアイテムを借りる"
    click_on "このアイテムを借りる"
    within("#borrowModal", visible: true) do
      expect(page).to have_content "貸出の手続き"
      fill_in "返却予定日", with: (Date.today + 1).to_s
      click_on "確定して借りる"
    end
    expect(page).to have_content "貸出処理が完了しました"
    expect(page).not_to have_button "このアイテムを借りる"
    expect(Lending.count).to eq 1
  end

  it "貸出中のアイテムで貸出ボタンが押せず現在貸出中と表示されること" do
    visit item_path(lent_item)

    expect(page).to_not have_button "このアイテムを借りる"

    expect(page).to have_button "現在貸出中です", disabled: true

    expect(Lending.count).to eq 0
  end

  it "メンテ中のアイテムには、借りるボタンが表示されず、現在メンテ中の押せないボタンが表示されること" do
    visit item_path(maintenance_item)

    expect(page).to_not have_button "現在貸出中です"
    expect(page).to_not have_button "このアイテムを借りる"

    expect(page).to have_button "現在メンテ中です", disabled: true
  end

  it "自分が借りているアイテムを返却できること" do
    lending = Lending.new(item: lent_item, lent_at: Date.current, due_at: Date.current, user: user)
    lending.save!(validate: false)

    visit lendings_path
    within ".card", text: "貸出中のMac" do
      click_on "返却する"
    end
    within("#returnedModal-#{lent_item.id}", visible: true) do
      expect(page).to have_content "返却の手続き"
      click_on "返却する"
    end

    expect(page).to have_content "返却処理が完了しました"
    expect(page).not_to have_button "返却する"

    visit item_path(lent_item)
    expect(page).to have_content "このアイテムを借りる"
  end
end
