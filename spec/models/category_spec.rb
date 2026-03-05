require 'rails_helper'
RSpec.describe Category, type: :model do
  describe 'バリデーションのテスト' do
    context 'カテゴリー名が正しく入力されている場合' do
      it '有効（バリデーション成功）になり、保存できること' do
        category = Category.new(name: "カテゴリ_#{SecureRandom.hex(4)}")
        expect(category).to be_valid
      end
    end

    context 'カテゴリー名が空っぽの場合' do
      it '無効（バリデーション失敗）になり、保存できないこと' do
        category = Category.new(name: "")
        expect(category).to_not be_valid
      end
    end

    context 'すでに同じ名前のカテゴリーが存在する場合' do
      it '無効（バリデーション失敗）になり、保存できないこと' do
        Category.new(name: "PC周辺機器")
        category = Category.new(name: "PC周辺機器")
        expect(category).to_not be_valid
        category.valid?
        expect(category.errors[:name]).to include("はすでに存在します")
      end
    end
  end
end
