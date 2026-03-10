require 'rails_helper'
RSpec.describe Lending, type: :model do
  let!(:random_password) { (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join }
  describe "返却ステータスの連動テスト" do
    it "返却日(returned_at)が記録されたら、紐づくアイテムが「貸出可」に戻ること" do
      category = Category.find_or_create_by!(name: "PC周辺機器")
      user = User.find_by(email: "lending_test@example.com") || User.create!(email: "lending_test@example.com", password: random_password, name: "借りる人")

      item = Item.create!(name: "MacBook", unique_id: "999-#{SecureRandom.hex(2)}", category: category, state: :available)
      lending = Lending.create!(item: item, user: user, lent_at: Time.current, due_at: Time.current)
      lending.update!(returned_at: Time.current)


      item.reload
      expect(item.state).to eq "available"
    end
  end

  it "貸出中のアイテムに対しては、新しく貸出データを登録できないこと" do
    category = Category.find_or_create_by!(name: "アイテム")
    user = User.find_by(email: "other@example.com") || User.create!(email: "other@example.com", password: random_password, name: "別の人")

    lent_item = Item.create!(name: "既存のアイテム", unique_id: "X01-#{SecureRandom.hex(2)}", category: category, state: :borrowed)
    new_lending = Lending.new(item: lent_item, user: user, lent_at: Time.current, due_at: Time.current + 1)

    expect(new_lending).to be_invalid

    new_lending.invalid?
    expect(new_lending.errors[:item]).to include("は現在貸出中のため、新しく借りることはできません")
  end
end
