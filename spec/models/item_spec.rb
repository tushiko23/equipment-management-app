require 'rails_helper'

RSpec.describe Item, type: :model do
  
  describe "バリデーションのテスト" do
    context "正常系（保存できる場合）" do
      it "すべての必須項目が正しく入力されていれば保存できること" do
        category = Category.create(name: "PC周辺機器")
        item = Item.new(name: "PC周辺機器",  unique_id: "9999", category: category, state: :available)
        expect(item).to be_valid
      end
    end

    context "異常系（保存できない場合）" do
      it "アイテム名が空欄だと保存できないこと" do
        category = Category.create(name: "PC周辺機器")
        item = Item.new(name: "",  unique_id: "9999", category: category, state: :available)
        expect(item).to_not be_valid
      end
      
      it "管理番号が空欄だと保存できないこと" do
        category = Category.create(name: "PC周辺機器")
        item = Item.new(name: "古いMacBook",  unique_id: "", category: category, state: :available)
        expect(item).to_not be_valid
      end

      it "カテゴリーが空欄だと保存できないこと" do
        item = Item.new(name: "古いMacBook",  unique_id: "9999", category: nil, state: :available)
        expect(item).to_not be_valid
      end

      it "管理番号に重複があると保存できないこと" do
        category = Category.create!(name: "カテゴリ_#{SecureRandom.hex(4)}")
        Item.create(name: "新しいMacBook", unique_id: "9999", category: category, state: :available)
        item = Item.new(name: "古いMacBook", unique_id: "9999", category: category, state: :available)
        expect(item).to_not be_valid

        item.valid?
        expect(item.errors[:unique_id]).to include("はすでに存在します")
      end
    end
  end
end
