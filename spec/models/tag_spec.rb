require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe "バリデーションのテスト" do
    context "正常系（保存できる場合）" do
      it "タグ名の大文字小文字が異なれば、重複とはみなされず保存できること" do
        Tag.create(name: "Ruby")
        another_tag = Tag.new(name: "ruby")
        expect(another_tag).to be_valid
      end
    end

    context "異常系（保存できない場合）" do
      it "タグに重複があると保存できないこと" do
        Tag.create(name: "PC")
        tag = Tag.new(name: "PC")
        expect(tag).to_not be_valid

        tag.valid?
        expect(tag.errors[:name]).to include("はすでに存在します")
      end
    end
  end
end
